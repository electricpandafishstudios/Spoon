-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2016 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Map = require "engine.Map"
local RoomsLoader = require "engine.generator.map.RoomsLoader"
require "engine.Generator"

--- @classmod engine.generator.map.Cavern
module(..., package.seeall, class.inherit(engine.Generator, RoomsLoader))

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.data = data
	self.grid_list = zone.grid_list
	self.zoom = data.zoom or 12
	self.hurst = data.hurst or 0.2
	self.lacunarity = data.lacunarity or 4
	self.octave = data.octave or 1
	self.door_chance = data.door_chance or nil
	self.min_floor = data.min_floor or 900
	self.noise = data.noise or "simplex"
	self.spots = {}

	RoomsLoader.init(self, data)
end

function _M:generate(lev, old_lev)
	print("Generating cavern")
	local noise = core.noise.new(2, self.hurst, self.lacunarity)
	local fills = {}
	local opens = {}
	local list = {}
	for i = 0, self.map.w - 1 do
		opens[i] = {}
		for j = 0, self.map.h - 1 do
			if noise[self.noise](noise, self.zoom * i / self.map.w, self.zoom * j / self.map.h, self.octave) > 0 then
				self.map(i, j, Map.TERRAIN, self:resolve("floor"))
				opens[i][j] = #list+1
				list[#list+1] = {x=i, y=j}
			else
				self.map(i, j, Map.TERRAIN, self:resolve("wall"))
			end
		end
	end

	local floodFill floodFill = function(x, y)
		local q = {{x=x,y=y}}
		local closed = {}
		while #q > 0 do
			local n = table.remove(q, 1)
			if opens[n.x] and opens[n.x][n.y] then
				closed[#closed+1] = n
				list[opens[n.x][n.y]] = nil
				opens[n.x][n.y] = nil
				q[#q+1] = {x=n.x-1, y=n.y}
				q[#q+1] = {x=n.x, y=n.y+1}
				q[#q+1] = {x=n.x+1, y=n.y}
				q[#q+1] = {x=n.x, y=n.y-1}

				q[#q+1] = {x=n.x+1, y=n.y-1}
				q[#q+1] = {x=n.x+1, y=n.y+1}
				q[#q+1] = {x=n.x-1, y=n.y-1}
				q[#q+1] = {x=n.x-1, y=n.y+1}
			end
		end
		return closed
	end

	-- Process all open spaces
	local groups = {}
	while next(list) do
		local i, l = next(list)
		local closed = floodFill(l.x, l.y)
		groups[#groups+1] = {id=id, list=closed}
		print("Floodfill group", i, #closed)
	end
	-- If nothing exists, regen
	if #groups == 0 then return self:generate(lev, old_lev) end

	-- Sort to find the biggest group
	table.sort(groups, function(a,b) return #a.list < #b.list end)
	local g = groups[#groups]
	if #g.list >= self.min_floor then
		print("Ok floodfill")
		for i = 1, #groups-1 do
			for j = 1, #groups[i].list do
				local jn = groups[i].list[j]
				self.map(jn.x, jn.y, Map.TERRAIN, self:resolve("wall"))
			end
		end
	else
		return self:generate(lev, old_lev)
	end

	local nb_room = util.getval(self.data.nb_rooms or 0)
	self.required_rooms = self.required_rooms or {}
	local rooms = {}

	-- Those we are required to have
	if #self.required_rooms > 0 then
		for i, rroom in ipairs(self.required_rooms) do
			local ok = false
			if type(rroom) == "table" and rroom.chance_room then
				if rng.percent(rroom.chance_room) then rroom = rroom[1] ok = true end
			else ok = true
			end

			if ok then
				local r = self:roomAlloc(rroom, #rooms+1, lev, old_lev)
				if r then rooms[#rooms+1] = r
				else self.force_recreate = true return end
				nb_room = nb_room - 1
			end
		end
	end

	while nb_room > 0 do
		local rroom
		while true do
			rroom = self.rooms[rng.range(1, #self.rooms)]
			if type(rroom) == "table" and rroom.chance_room then
				if rng.percent(rroom.chance_room) then rroom = rroom[1] break end
			else
				break
			end
		end

		local r = self:roomAlloc(rroom, #rooms+1, lev, old_lev)
		if r then rooms[#rooms+1] = r end
		nb_room = nb_room - 1
	end

	-- Did any rooms request a tunnel ?
	for i, spot in ipairs(self.spots) do if spot.make_tunnel then
		local es = {}
		if spot.tunnel_dir then
			core.fov.calc_beam(spot.x, spot.y, self.map.w, self.map.h, 100, spot.tunnel_dir, 90,
				function(_, lx, ly) return false end,
				function(_, lx, ly)
					if (lx ~= spot.x or ly ~= spot.y) and not self.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then es[#es+1] = {x=lx, y=ly} end
				end,
			nil)
		else
			core.fov.calc_circle(spot.x, spot.y, self.map.w, self.map.h, 100,
				function(_, lx, ly) return false end,
				function(_, lx, ly)
					if (lx ~= spot.x or ly ~= spot.y) and not self.map:checkEntity(lx, ly, Map.TERRAIN, "block_move") then es[#es+1] = {x=lx, y=ly} end
				end,
			nil)
		end

		local ex, ey = math.floor(self.map.w / 2), math.floor(self.map.h / 2)
		if #es > 0 then
			table.sort(es, function(a, b) return core.fov.distance(spot.x, spot.y, a.x, a.y) < core.fov.distance(spot.x, spot.y, b.x, b.y) end)
			local e = es[1]
			ex, ey = e.x, e.y
		end

		self:tunnel(spot.x, spot.y, ex, ey, -i)
	end end

	if self.door_chance then
		self:addDoors()
	end

	return self:makeStairsInside(lev, old_lev, self.spots)
end

function _M:addDoors()
	local possible = {}
	for i = 1, self.map.w - 2 do
		for j = 1, self.map.h - 2 do
			local g4 = self.map:checkEntity(i-1, j, Map.TERRAIN, "block_move")
			local g6 = self.map:checkEntity(i+1, j, Map.TERRAIN, "block_move")
			local g2 = self.map:checkEntity(i, j+1, Map.TERRAIN, "block_move")
			local g8 = self.map:checkEntity(i, j-1, Map.TERRAIN, "block_move")

			if     g4 and g6 and not g2 and not g8 then possible[#possible+1] = {x=i, y=j, dir="46"}
			elseif not g4 and not g6 and g2 and g8 then possible[#possible+1] = {x=i, y=j, dir="82"} end
		end
	end

	table.shuffle(possible)

	local delspot = function(x, y)
		for i, d in ipairs(possible) do
			if d.x == x and d.y == y then table.remove(possible, i) return end
		end
	end

	while #possible > 0 do
		local d = table.remove(possible)

		if rng.percent(self.door_chance) then
			self.map(d.x, d.y, Map.TERRAIN, self:resolve("door"))
			delspot(d.x-1, d.y) delspot(d.x+1, d.y)
			delspot(d.x, d.y-1) delspot(d.x, d.y+1)
		end
	end
end

--- Create the stairs inside the level
function _M:makeStairsInside(lev, old_lev, spots)
	-- Put down stairs
	local dx, dy
	if lev < self.zone.max_level or self.data.force_last_stair then
		while true do
			dx, dy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
			if not self.map:checkEntity(dx, dy, Map.TERRAIN, "block_move") and not self.map.room_map[dx][dy].special then
				self.map(dx, dy, Map.TERRAIN, self:resolve("down"))
				self.map.room_map[dx][dy].special = "exit"
				break
			end
		end
	end

	-- Put up stairs
	local ux, uy
	while true do
		ux, uy = rng.range(1, self.map.w - 1), rng.range(1, self.map.h - 1)
		if not self.map:checkEntity(ux, uy, Map.TERRAIN, "block_move") and not self.map.room_map[ux][uy].special then
			self.map(ux, uy, Map.TERRAIN, self:resolve("up"))
			self.map.room_map[ux][uy].special = "exit"
			break
		end
	end

	return ux, uy, dx, dy, spots
end
