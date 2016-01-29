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
local lom = require "lxp.lom"
local mime = require "mime"
require "engine.Generator"

--- @classmod engine.generator.map.Static
module(..., package.seeall, class.inherit(engine.Generator))

auto_handle_spot_offsets = true

function _M:init(zone, map, level, data)
	engine.Generator.init(self, zone, map, level)
	self.grid_list = zone.grid_list
	self.subgen = {}
	self.spots = {}
	self.data = data
	data.__import_offset_x = data.__import_offset_x or 0
	data.__import_offset_y = data.__import_offset_y or 0

	if data.adjust_level then
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=data.adjust_level[1], max=data.adjust_level[2]}
	else
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=0, max=0}
	end

	self:loadMap(data.map)
end

function _M:getMapFile(file)
	-- Found in the zone itself ?
	if file:find("^!") then return self.zone:getBaseName().."/maps/"..file:sub(2)..".lua" end

	local _, _, addon, rfile = file:find("^([^+]+)%+(.+)$")
	if addon and rfile then
		return "/data-"..addon.."/maps/"..rfile..".lua"
	end
	return "/data/maps/"..file..".lua"
end

function _M:getLoader(t)
	return {
		level = self.level,
		zone = self.zone,
		data = self.data,
		Map = require("engine.Map"),
		grid_class = self.zone.grid_class,
		trap_class = self.zone.trap_class,
		npc_class = self.zone.npc_class,
		object_class = self.zone.object_class,
		specialList = function(kind, files)
			if kind == "terrain" then
				self.grid_list = self.zone.grid_class:loadList(files)
			elseif kind == "trap" then
				self.trap_list = self.zone.trap_class:loadList(files)
			elseif kind == "object" then
				self.object_list = self.zone.object_class:loadList(files)
			elseif kind == "actor" then
				self.npc_list = self.zone.npc_class:loadList(files)
			else
				error("kind unsupported")
			end
		end,
		subGenerator = function(g)
			self.subgen[#self.subgen+1] = g
		end,
		defineTile = function(char, grid, obj, actor, trap, status, spot)
			t[char] = {grid=grid, object=obj, actor=actor, trap=trap, status=status, define_spot=spot}
		end,
		quickEntity = function(char, e, status, spot)
			if type(e) == "table" then
				local e = self.zone.grid_class.new(e)
				t[char] = {grid=e, status=status, define_spot=spot}
			else
				t[char] = t[e]
			end
		end,
		prepareEntitiesList = function(type, class, file)
			local list = require(class):loadList(file)
			self.level:setEntitiesList(type, list, true)
		end,
		prepareEntitiesRaritiesList = function(type, class, file)
			local list = require(class):loadList(file)
			list = game.zone:computeRarities(type, list, game.level, nil)
			self.level:setEntitiesList(type, list, true)
		end,
		setStatusAll = function(s) self.status_all = s end,
		addData = function(t)
			table.merge(self.level.data, t, true)
		end,
		getMap = function(t)
			return self.map
		end,
		checkConnectivity = function(dst, src, type, subtype)
			self.spots[#self.spots+1] = {x=dst[1], y=dst[2], check_connectivity=src, type=type or "static", subtype=subtype or "static"}
		end,
		addSpot = function(dst, type, subtype, additional)
			local spot = {x=self.data.__import_offset_x+dst[1], y=self.data.__import_offset_y+dst[2], type=type or "static", subtype=subtype or "static"}
			table.update(spot, additional or {})
			self.spots[#self.spots+1] = spot
		end,
		addZone = function(dst, type, subtype, additional)
			local zone = {x1=self.data.__import_offset_x+dst[1], y1=self.data.__import_offset_y+dst[2], x2=self.data.__import_offset_x+dst[3], y2=self.data.__import_offset_y+dst[4], type=type or "static", subtype=subtype or "static"}
			table.update(zone, additional or {})
			self.level.custom_zones = self.level.custom_zones or {}
			self.level.custom_zones[#self.level.custom_zones+1] = zone
		end,
		updateZones = function(type, subtype, update)
			for i, z in ipairs(self.level.custom_zones or {}) do update(z) end
		end,
		-- This is the module's responsability to invoke zone:runPostGeneration(level)
		onGenerated = function(fct)
			self.level.post_gen_callbacks = self.level.post_gen_callbacks or {}
			self.level.post_gen_callbacks[#self.level.post_gen_callbacks+1] = fct
		end,
	}
end

function _M:loadLuaInEnv(g, file, code)
	local f, err
	if file then f, err = loadfile(file)
	else f, err = loadstring(code) end
	if not f and err then error(err) end
	setfenv(f, setmetatable(g, {__index=_G}))
	return f()
end

function _M:tmxLoad(file)
	file = file:gsub("%.lua$", ".tmx")
	if not fs.exists(file) then return end
	print("Static generator using file", file)
	local f = fs.open(file, "r")
	local data = f:read(10485760)
	f:close()

	local t = {}
	local g = self:getLoader(t)
	local map = lom.parse(data)
	local mapprops = {}
	if map:findOne("properties") then mapprops = map:findOne("properties"):findAllAttrs("property", "name", "value") end
	local w, h = tonumber(map.attr.width), tonumber(map.attr.height)
	local tw, th = tonumber(map.attr.tilewidth), tonumber(map.attr.tileheight)
	local chars = {}
	local start_tid, end_tid = nil, nil
	for _, tileset in ipairs(map:findAll("tileset")) do
		if tileset:findOne("properties") then for name, value in pairs(tileset:findOne("properties"):findAllAttrs("property", "name", "value")) do
			if name == "load_terrains" then
				local list = self:loadLuaInEnv(g, nil, "return "..value) or {}
				self.zone.grid_class:loadList(list, nil, self.grid_list, nil, self.grid_list.__loaded_files)
			elseif name == "load_traps" then
				local list = self:loadLuaInEnv(g, nil, "return "..value) or {}
				self.zone.trap_class:loadList(list, nil, self.trap_list, nil, self.trap_list.__loaded_files)
			elseif name == "load_objects" then
				local list = self:loadLuaInEnv(g, nil, "return "..value) or {}
				self.zone.object_class:loadList(list, nil, self.object_list, nil, self.object_list.__loaded_files)
			elseif name == "load_actors" then
				local list = self:loadLuaInEnv(g, nil, "return "..value) or {}
				self.zone.npc_class:loadList(list, nil, self.npc_list, nil, self.npc_list.__loaded_files)
			end
		end end

		local firstgid = tonumber(tileset.attr.firstgid)
		for _, tile in ipairs(tileset:findAll("tile")) do
			local tid = tonumber(tile.attr.id + firstgid)
			local display = tile:findOne("property", "name", "display")
			local id = tile:findOne("property", "name", "id")
			local data_id = tile:findOne("property", "name", "data_id")
			local custom = tile:findOne("property", "name", "custom")
			local is_start = tile:findOne("property", "name", "start")
			local is_end = tile:findOne("property", "name", "end") or tile:findOne("property", "name", "stop")
			if display then
				chars[tid] = display.attr.value
			elseif id then
				t[tid] = id.attr.value
			elseif data_id then
				t[tid] = self.data[data_id.attr.value]
			elseif custom then
				local ret = self:loadLuaInEnv(g, nil, "return "..custom.attr.value)
				t[tid] = ret
			end
			if is_start then start_tid = tid end
			if is_end then end_tid = tid end
		end
	end

	local rotate = "default"
	if mapprops.rotate then
		rotate = self:loadLuaInEnv(g, nil, "return "..mapprops.rotate) or mapprops.rotate
	end

	if mapprops.status_all then
		self.status_all = self:loadLuaInEnv(g, nil, "return "..mapprops.status_all) or {}
	end

	if mapprops.add_data then
		table.merge(self.level.data, self:loadLuaInEnv(g, nil, "return "..mapprops.add_data) or {}, true)
	end

	if mapprops.lua then
		self:loadLuaInEnv(g, nil, "return "..mapprops.lua)
	end

	local m = { w=w, h=h }

	local function rotate_coords(i, j)
		local ii, jj = i, j
		if rotate == "flipx" then ii, jj = m.w - i + 1, j
		elseif rotate == "flipy" then ii, jj = i, m.h - j + 1
		elseif rotate == "90" then ii, jj = j, m.w - i + 1
		elseif rotate == "180" then ii, jj = m.w - i + 1, m.h - j + 1
		elseif rotate == "270" then ii, jj = m.h - j + 1, i
		end
		return ii, jj
	end
	local function populate(i, j, c, tid)
		local ii, jj = rotate_coords(i, j)

		m[ii] = m[ii] or {}
		if type(c) == "string" then
			m[ii][jj] = c
		else
			m[ii][jj] = m[ii][jj] or {}
			table.update(m[ii][jj], c)
		end
		if tid == start_tid then m.startx = ii - 1 m.starty = jj - 1 m.start_rotated = true end
		if tid == end_tid then m.endx = ii - 1 m.endy = jj - 1 m.end_rotated = true end
	end

	self.gen_map = m
	self.tiles = t

	self.map.w = m.w
	self.map.h = m.h

	for _, layer in ipairs(map:findAll("layer")) do
		local mapdata = layer:findOne("data")
		local layername = layer.attr.name:lower()
		if layername == "terrain" then layername = "grid" end

		if mapdata.attr.encoding == "base64" then
			local b64 = mime.unb64(mapdata[1]:trim())
			local data
			if mapdata.attr.compression == "zlib" then data = zlib.decompress(b64)
			elseif not mapdata.attr.compression then data = b64
			else error("tmx map compression unsupported: "..mapdata.attr.compression)
			end
			local gid, i = nil, 1
			local x, y = 1, 1
			while i <= #data do
				gid, i = struct.unpack("<I4", data, i)
				if chars[gid] then populate(x, y, chars[id])
				else populate(x, y, {[layername] = gid}, gid)
				end
				x = x + 1
				if x > w then x = 1 y = y + 1 end
			end
		elseif mapdata.attr.encoding == "csv" then
			local data = mapdata[1]:gsub("[^,0-9]", ""):split(",")
			local x, y = 1, 1
			for i, gid in ipairs(data) do
				gid = tonumber(gid)
				if chars[gid] then populate(x, y, chars[id])
				else populate(x, y, {[layername] = gid}, gid)
				end
				x = x + 1
				if x > w then x = 1 y = y + 1 end
			end
		elseif not mapdata.attr.encoding then
			local data = mapdata:findAll("tile")
			local x, y = 1, 1
			for i, tile in ipairs(data) do
				local gid = tonumber(tile.attr.gid)
				if chars[gid] then populate(x, y, chars[id])
				else populate(x, y, {[layername] = gid}, gid)
				end
				x = x + 1
				if x > w then x = 1 y = y + 1 end
			end
		end
	end

	self.add_attrs_later = {}

	for _, og in ipairs(map:findAll("objectgroup")) do
		for _, o in ipairs(map:findAll("object")) do
			local props = o:findOne("properties"):findAllAttrs("property", "name", "value")

			if og.attr.name:find("^addSpot") then
				local x, y, w, h = math.floor(tonumber(o.attr.x) / tw), math.floor(tonumber(o.attr.y) / th), math.floor(tonumber(o.attr.width) / tw), math.floor(tonumber(o.attr.height) / th)
				if props.start then m.startx = x m.starty = y end
				if props['end'] then m.endx = x m.endy = y end
				if props.type and props.subtype then
					for i = x, x + w do for j = y, y + h do
						local i, j = rotate_coords(i, j)
						g.addSpot({i, j}, props.type, props.subtype)
					end end
				end
			elseif og.attr.name:find("^addZone") then
				local x, y, w, h = math.floor(tonumber(o.attr.x) / tw), math.floor(tonumber(o.attr.y) / th), math.floor(tonumber(o.attr.width) / tw), math.floor(tonumber(o.attr.height) / th)
				if props.type and props.subtype then
					local i1, j2 = rotate_coords(x, y)
					local i2, j2 = rotate_coords(x + w, y + h)
					g.addZone({x, y, x + w, y + h}, props.type, props.subtype)
				end
			elseif og.attr.name:find("^attrs") then
				local x, y, w, h = math.floor(tonumber(o.attr.x) / tw), math.floor(tonumber(o.attr.y) / th), math.floor(tonumber(o.attr.width) / tw), math.floor(tonumber(o.attr.height) / th)
				for k, v in pairs(props) do
					for i = x, x + w do for j = y, y + h do
						local i, j = rotate_coords(i, j)
						self.add_attrs_later[#self.add_attrs_later+1] = {x=i, y=j, key=k, value=self:loadLuaInEnv(g, nil, "return "..v)}
						print("====", i, j, k)
					end end
				end
			end
		end
	end

	m.startx = m.startx or math.floor(m.w / 2)
	m.starty = m.starty or math.floor(m.h / 2)
	m.endx = m.endx or math.floor(m.w / 2)
	m.endy = m.endy or math.floor(m.h / 2)
	if rotate == "flipx" then
		if not m.start_rotated then m.startx = m.w - m.startx - 1 end
		if not m.end_rotated then m.endx   = m.w - m.endx - 1 end
	elseif rotate == "flipy" then
		if not m.start_rotated then m.starty = m.h - m.starty - 1 end
		if not m.end_rotated then m.endy   = m.h - m.endy - 1 end
	elseif rotate == "90" then
		if not m.start_rotated then m.startx, m.starty = m.starty, m.w - m.startx - 1 end
		if not m.end_rotated then m.endx,   m.endy   = m.endy,   m.w - m.endx   - 1 end
		m.w, m.h = m.h, m.w
	elseif rotate == "180" then
		if not m.start_rotated then m.startx, m.starty = m.w - m.startx - 1, m.h - m.starty - 1 end
		if not m.end_rotated then m.endx,   m.endy   = m.w - m.endx   - 1, m.h - m.endy   - 1 end
	elseif rotate == "270" then
		if not m.start_rotated then m.startx, m.starty = m.h - m.starty - 1, m.startx end
		if not m.end_rotated then m.endx,   m.endy   = m.h - m.endy   - 1, m.endx end
		m.w, m.h = m.h, m.w
	end

	print("[STATIC TMX MAP] size", m.w, m.h)
	return true
end

function _M:loadMap(file)
	local t = {}

	file = self:getMapFile(file)
	if self:tmxLoad(file) then return end

	print("Static generator using file", file)
	local g = self:getLoader(t)
	local ret, err = self:loadLuaInEnv(g, file)
	if not ret and err then error(err) end
	if type(ret) == "string" then ret = ret:split("\n") end

	local m = { w=#(ret[1]), h=#ret }

	local rotate = util.getval(g.rotates or "default")
	local function populate(i, j, c)
		local ii, jj = i, j

		if rotate == "flipx" then ii, jj = m.w - i + 1, j
		elseif rotate == "flipy" then ii, jj = i, m.h - j + 1
		elseif rotate == "90" then ii, jj = j, m.w - i + 1
		elseif rotate == "180" then ii, jj = m.w - i + 1, m.h - j + 1
		elseif rotate == "270" then ii, jj = m.h - j + 1, i
		end

		m[ii] = m[ii] or {}
		m[ii][jj] = c
	end

	-- Read the map
	if type(ret[1]) == "string" then
		for j, line in ipairs(ret) do
			local i = 1
			for c in line:gmatch(".") do
				populate(i, j, c)
				i = i + 1
			end
		end
	else
		for j, line in ipairs(ret) do
			for i, c in ipairs(line) do
				populate(i, j, c)
			end
		end
	end

	m.startx = g.startx or math.floor(m.w / 2)
	m.starty = g.starty or math.floor(m.h / 2)
	m.endx = g.endx or math.floor(m.w / 2)
	m.endy = g.endy or math.floor(m.h / 2)

	if rotate == "flipx" then
		m.startx = m.w - m.startx + 1
		m.endx   = m.w - m.endx   + 1
	elseif rotate == "flipy" then
		m.starty = m.h - m.starty + 1
		m.endy   = m.h - m.endy   + 1
	elseif rotate == "90" then
		m.startx, m.starty = m.starty, m.w - m.startx + 1
		m.endx,   m.endy   = m.endy,   m.w - m.endx   + 1
		m.w, m.h = m.h, m.w
	elseif rotate == "180" then
		m.startx, m.starty = m.w - m.startx + 1, m.h - m.starty + 1
		m.endx,   m.endy   = m.w - m.endx   + 1, m.h - m.endy   + 1
	elseif rotate == "270" then
		m.startx, m.starty = m.h - m.starty + 1, m.startx
		m.endx,   m.endy   = m.h - m.endy   + 1, m.endx
		m.w, m.h = m.h, m.w
	end

	self.gen_map = m
	self.tiles = t

	self.map.w = m.w
	self.map.h = m.h
	print("[STATIC MAP] size", m.w, m.h)
end

function _M:resolve(typ, c)
	local res
	if typ then
		if not self.tiles[c] or not self.tiles[c][typ] then return end
		res = self.tiles[c][typ]
	else
		if not self.tiles[c] then return end
		res = self.tiles[c]
	end
	if type(res) == "function" then
		return self.grid_list[res()]
	elseif type(res) == "table" and (res.__ATOMIC or res.__CLASSNAME) then
		return res
	elseif type(res) == "table" then
		return self.grid_list[res[rng.range(1, #res)]]
	else
		return self.grid_list[res]
	end
end

function _M:generate(lev, old_lev)
	local spots = {}

	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		local c = self.gen_map[i][j]
		local g
		if type(c) == "string" then g = self:resolve("grid", c)
		else g = self:resolve(nil, c.grid) end
		if g then
			if g.force_clone then g = g:clone() end
			g:resolve()
			g:resolve(nil, true)
			self.map(i-1, j-1, Map.TERRAIN, g)
			g:check("addedToLevel", self.level, i-1, j-1)
			g:check("on_added", self.level, i-1, j-1)
		end

		if self.status_all then
			local s = table.clone(self.status_all)
			if s.lite then self.level.map.lites(i-1, j-1, true) s.lite = nil end
			if s.remember then self.level.map.remembers(i-1, j-1, true) s.remember = nil end
			if s.special then self.map.room_map[i-1][j-1].special = s.special s.special = nil end
			if s.room_map then for k, v in pairs(s.room_map) do self.map.room_map[i-1][j-1][k] = v end s.room_map = nil end
			if pairs(s) then for k, v in pairs(s) do self.level.map.attrs(i-1, j-1, k, v) end end
		end
	end end

	-- generate the rest after because they might need full map data to be correctly made
	for i = 1, self.gen_map.w do for j = 1, self.gen_map.h do
		local c = self.gen_map[i][j]
		local actor, trap, object, status, define_spot
		if type(c) == "string" then
			actor = self.tiles[c] and self.tiles[c].actor
			trap = self.tiles[c] and self.tiles[c].trap
			object = self.tiles[c] and self.tiles[c].object
			trigger = self.tiles[c] and self.tiles[c].trigger
			status = self.tiles[c] and self.tiles[c].status
			define_spot = self.tiles[c] and self.tiles[c].define_spot
		else
			actor = c.actor and self.tiles[c.actor]
			trap = c.trap and self.tiles[c.trap]
			object = c.object and self.tiles[c.object]
			trigger = c.trigger and self.tiles[c.trigger]
			status = c.status and self.tiles[c.status]
			define_spot = c.define_spot and self.tiles[c.define_spot]
		end

		if trigger then
			local t, mod
			if type(trigger) == "string" then t = self.zone:makeEntityByName(self.level, "trigger", trigger)
			elseif type(trigger) == "table" and trigger.random_filter then mod = trigger.entity_mod t = self.zone:makeEntity(self.level, "terrain", trigger.random_filter, nil, true)
			else t = self.zone:finishEntity(self.level, "terrain", trigger)
			end

			if t then if mod then t = mod(t) end self:roomMapAddEntity(i-1, j-1, "trigger", t) end
		end

		if object then
			local o, mod
			if type(object) == "string" then o = self.zone:makeEntityByName(self.level, "object", object)
			elseif type(object) == "table" and object.random_filter then mod = object.entity_mod o = self.zone:makeEntity(self.level, "object", object.random_filter, nil, true)
			else o = self.zone:finishEntity(self.level, "object", object)
			end

			if o then if mod then o = mod(o) end self:roomMapAddEntity(i-1, j-1, "object", o) end
		end

		if trap then
			local t, mod
			if type(trap) == "string" then t = self.zone:makeEntityByName(self.level, "trap", trap)
			elseif type(trap) == "table" and trap.random_filter then mod = trap.entity_mod t = self.zone:makeEntity(self.level, "trap", trap.random_filter, nil, true)
			else t = self.zone:finishEntity(self.level, "trap", trap)
			end
			if t then if mod then t = mod(t) end self:roomMapAddEntity(i-1, j-1, "trap", t) end
		end

		if actor then
			local m, mod
			if type(actor) == "string" then m = self.zone:makeEntityByName(self.level, "actor", actor)
			elseif type(actor) == "table" and actor.random_filter then mod = actor.entity_mod m = self.zone:makeEntity(self.level, "actor", actor.random_filter, nil, true)
			else m = self.zone:finishEntity(self.level, "actor", actor)
			end
			if m then if mod then m = mod(m) end self:roomMapAddEntity(i-1, j-1, "actor", m) end
		end

		if status then
			local s = table.clone(status)
			if s.lite then self.level.map.lites(i-1, j-1, true) s.lite = nil end
			if s.remember then self.level.map.remembers(i-1, j-1, true) s.remember = nil end
			if s.special then self.map.room_map[i-1][j-1].special = s.special s.special = nil end
			if s.room_map then for k, v in pairs(s.room_map) do self.map.room_map[i-1][j-1][k] = v end s.room_map = nil end
			if pairs(s) then for k, v in pairs(s) do self.level.map.attrs(i-1, j-1, k, v) end end
		end

		if define_spot then
			define_spot = table.clone(define_spot)
			assert(define_spot.type, "defineTile auto spot without type field")
			assert(define_spot.subtype, "defineTile auto spot without subtype field")
			define_spot.x = self.data.__import_offset_x+i-1
			define_spot.y = self.data.__import_offset_y+j-1
			self.spots[#self.spots+1] = define_spot
		end
	end end

	if self.add_attrs_later then for _, attr in ipairs(self.add_attrs_later) do
		if attr.key == "lite" then self.level.map.lites(attr.x, attr.y, true) end
		if attr.key == "remember" then self.level.map.remembers(attr.x, attr.y, true) end
		if attr.key == "special" then self.map.room_map[attr.x][attr.y].special = s.special end
		if attr.key == "room_map" then for k, v in pairs(s.room_map) do self.map.room_map[attr.x][attr.y][k] = v end end
		self.level.map.attrs(attr.x, attr.y, attr.key, attr.value)
	end end

	self:triggerHook{"MapGeneratorStatic:subgenRegister", mapfile=self.data.map, list=self.subgen}

	for i = 1, #self.subgen do
		local g = self.subgen[i]
		local data = g.data
		if type(data) == "string" and data == "pass" then data = self.data end

		local map = self.zone.map_class.new(g.w, g.h)
		data.__import_offset_x = self.data.__import_offset_x+g.x
		data.__import_offset_y = self.data.__import_offset_y+g.y
		local generator = require(g.generator).new(
			self.zone,
			map,
			self.level,
			data
		)
		local ux, uy, dx, dy, subspots = generator:generate(lev, old_lev)

		if g.overlay then
			self.map:overlay(map, g.x, g.y)
		else
			self.map:import(map, g.x, g.y)
		end

		if not generator.auto_handle_spot_offsets then
			for _, spot in ipairs(subspots) do
				spot.x = spot.x + data.__import_offset_x
				spot.y = spot.y + data.__import_offset_y
			end
		end

		table.append(self.spots, subspots)

		if g.define_up then self.gen_map.startx, self.gen_map.starty = ux + self.data.__import_offset_x+g.x, uy + self.data.__import_offset_y+g.y end
		if g.define_down then self.gen_map.endx, self.gen_map.endy = dx + self.data.__import_offset_x+g.x, dy + self.data.__import_offset_y+g.y end
	end

	if self.gen_map.startx and self.gen_map.starty then
		self.map.room_map[self.gen_map.startx][self.gen_map.starty].special = "exit"
	end
	if self.gen_map.endx and self.gen_map.endy then
		self.map.room_map[self.gen_map.endx][self.gen_map.endy].special = "exit"
	end
	return self.gen_map.startx, self.gen_map.starty, self.gen_map.endx, self.gen_map.endy, self.spots
end
