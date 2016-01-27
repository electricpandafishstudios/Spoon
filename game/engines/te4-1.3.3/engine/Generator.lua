-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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
module(..., package.seeall, class.make)

function _M:init(zone, map, level, spots)
	self.zone = zone
	self.map = map
	self.level = level
	self.spots = spots

	-- Setup the map's room-map
	if not map.room_map then
		map.room_map = {}
		for i = 0, map.w - 1 do
			map.room_map[i] = {}
			for j = 0, map.h - 1 do
				map.room_map[i][j] = {}
			end
		end
	end
end

function _M:generate()
end

function _M:resolve(c, list, force)
	local res = force and c or self.data[c]
	if type(res) == "function" then
		res = res()
	elseif type(res) == "table" then
		res = res[rng.range(1, #res)]
	else
		res = res
	end
	if not res then return end
	res = (list or self.grid_list)[res]
	if not res then return end
	if res.force_clone then
		res = res:clone()
	end
	res:resolve()
	res:resolve(nil, true)
	return res
end

function _M:roomMapAddEntity(i, j, type, e)
	self.map.room_map[i] = self.map.room_map[i] or {}
	self.map.room_map[i][j] = self.map.room_map[i][j] or {}
	self.map.room_map[i][j].add_entities = self.map.room_map[i][j].add_entities or {}
	local rm = self.map.room_map[i][j].add_entities
	rm[#rm+1] = {type, e}
	e:added() -- we do it here to make sure uniques are uniques
end

local Gridlist = class.make{}

function _M:makeGridList()
	return Gridlist.new()
end

function Gridlist:init()
	self.list = {}
end

function Gridlist:add(x, y, data)
	if data == nil then data = true end
	if not self.list[x] then self.list[x] = {} end
	self.list[x][y] = data
end

function Gridlist:remove(x, y)
	if not self.list[x] then return end
	self.list[x][y] = nil
	if not next(self.list[x]) then self.list[x] = nil end
end

function Gridlist:has(x, y)
	if not self.list[x] then return end
	return self.list[x][y]
end

function Gridlist:toList()
	local list = {}
	for x, yy in pairs(self.list) do for y, data in pairs(yy) do
		list[#list+1] = {x=x, y=y, data=data}
	end end 
	return list
end

function Gridlist:count()
	local nb = 0
	for x, yy in pairs(self.list) do for y, data in pairs(yy) do
		nb = nb + 1
	end end 
	return nb
end
