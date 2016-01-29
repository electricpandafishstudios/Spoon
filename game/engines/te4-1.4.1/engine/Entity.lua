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

local Shader = require "engine.Shader"
local Particles = require "engine.Particles"

--- An entity is anything that goes on a map, terrain features, objects, monsters, player, ...  
-- Usually there is no need to use it directly, and it is better to use specific engine.Grid, engine.Actor or engine.Object
-- classes. Most modules will want to subclass those anyway to add new comportments
-- @classmod engine.Entity
module(..., package.seeall, class.make)

local next_uid = 1
local entities_load_functions = {}


_M.__mo_final_repo = {}
--- Fields we shouldn't save
_M._no_save_fields = { _shader = true }
 --- Subclasses can change it to know where they are on the map
_M.__position_aware = false

-- Setup the uids & Map object repository as a weak value table, when the entities are no more used anywhere else they disappear from there too
setmetatable(__uids, {__mode="v"})
setmetatable(_M.__mo_final_repo, {__mode="k"})

--- Invalidates the whole Map Object repository
-- @static
function _M:invalidateAllMO()
	setmetatable(_M.__mo_final_repo, {__mode="k"})
end

--- recursive copy
-- @param[type=table] dst the destination table
-- @param[type=table] src the source table
-- @param[type=boolean] deep copy ALL the things
local function copy_recurs(dst, src, deep)
	for k, e in pairs(src) do
		if type(e) == "table" and (e.__ATOMIC or e.__CLASSNAME) then
			dst[k] = e
		elseif dst[k] == nil then
			if deep then
				dst[k] = {}
				copy_recurs(dst[k], e, deep)
			else
				dst[k] = e
			end
		elseif type(dst[k]) == "table" and type(e) == "table" and not e.__ATOMIC and not e.__CLASSNAME then
			copy_recurs(dst[k], e, deep)
		end
	end
end

--- Import base into entity
-- @param[type=table] t
-- @param[type=table] base
local function importBase(t, base)
	local temp = table.clone(base, true, {uid=true, define_as = true})
	if base.onEntityMerge then base:onEntityMerge(temp) end
	table.mergeAppendArray(temp, t, true)
	t = temp
	t.base = nil
	return t
end

--- Create a new entity with a base
-- calls `importBase`
-- @static
-- @param[type=table] t
-- @param[type=table] base
function _M:fromBase(t, base)
	if not base then base = t.base end
	assert(base, "no base given to Entity.fromBase")
	t = importBase(t, base)
	return self.new(t)
end

--- Initialize an entity
-- Any subclass MUST call this constructor
-- @param[type=table] t a table defining the basic properties of the entity
-- @param[type=boolean] no_default alternate settings that override the defaults
-- @usage Entity.new{display='#', color_r=255, color_g=255, color_b=255}
function _M:init(t, no_default)
	t = t or {}

	self.uid = next_uid
	__uids[self.uid] = self
	next_uid = next_uid + 1

	for k, e in pairs(t) do
		if k ~= "__CLASSNAME" and k ~= "uid" then
			local ee = e
			if type(e) == "table" and not e.__ATOMIC and not e.__CLASSNAME then ee = table.clone(e, true) end
			self[k] = ee
		end
	end

	if config.settings.cheat and not self._no_upvalues_check then
		local ok, err = table.check(
			self,
			function(t, where, v, tv)
				if tv ~= "function" then return true end
				local n, v = debug.getupvalue(v, 1)
				if not n then return true end
				return nil, ("%s has upvalue %s"):format(tostring(where), tostring(n))
			end,
			function(value) return not value._allow_upvalues end)
		if not ok then
			error("Entity definition has a closure: "..err)
		end
	end

	if self.color then
		self.color_r = self.color.r
		self.color_g = self.color.g
		self.color_b = self.color.b
		self.color = nil
	end
	if self.back_color then
		self.color_br = self.back_color.r
		self.color_bg = self.back_color.g
		self.color_bb = self.back_color.b
		self.back_color = nil
	end
	if self.tint then
		self.tint_r = self.tint.r / 255
		self.tint_g = self.tint.g / 255
		self.tint_b = self.tint.b / 255
		self.tint = nil
	end

	if not no_default then
		self.image = self.image or nil
		self.display = self.display or '.'
		self.color_r = self.color_r or 0
		self.color_g = self.color_g or 0
		self.color_b = self.color_b or 0
		self.color_br = self.color_br or -1
		self.color_bg = self.color_bg or -1
		self.color_bb = self.color_bb or -1
		self.tint_r = self.tint_r or 1
		self.tint_g = self.tint_g or 1
		self.tint_b = self.tint_b or 1
	end

	if self.unique and type(self.unique) ~= "string" then self.unique = self.name end

	self.changed = true
	self.__particles = self.__particles or {}

	if self.embed_particles then
		local Particles = require "engine.Particles"
		for i, pd in ipairs(self.embed_particles) do
			self:addParticles(Particles.new(pd.name, pd.rad or 1, pd.args))
		end
	end

end

--- If we are cloned we need a new uid
-- flags entity as changed
-- @param src source of event, not used by default
function _M:cloned(src)
	self.uid = next_uid
	__uids[self.uid] = self
	next_uid = next_uid + 1

	self.changed = true
end

--- If we are replaced we need a new uid
-- flags entity as changed
-- @param[type=boolean] isdone
-- @param new
function _M:replacedWith(isdone, new)
	if not isdone then __uids[self.uid] = nil
	else
		self.uid = next_uid
		__uids[self.uid] = self
		next_uid = next_uid + 1
		self.changed = true
	end
end

_M.__autoload = {}
--- Do we delay the load for this entity or not
_M.loadNoDelay = true
--- If we are loaded we need a new uid
-- flags entity as changed
function _M:loaded()
	local ouid = self.uid
	if __uids[self.uid] and __uids[self.uid] == self.uid then __uids[self.uid] = nil end
	self.uid = next_uid
	__uids[self.uid] = self
	next_uid = next_uid + 1

	self.changed = true

	-- hackish :/
	if self.autoLoadedAI then self:autoLoadedAI() end

	self:defineDisplayCallback()
end

--- Change the entity's uid
-- <strong>*WARNING*</strong>: ONLY DO THIS IF YOU KNOW WHAT YOU ARE DOING!. YOU DO NOT !
-- @param newuid the new uid
function _M:changeUid(newuid)
	if __uids[self.uid] and __uids[self.uid] == self.uid then __uids[self.uid] = nil end
	self.uid = newuid
	__uids[self.uid] = self
end

--- Try to remove all "un-needed" effects, fields, ... for a clean export
-- This does nothing by default
function _M:stripForExport()
end

--- Setup minimap color for this entity
-- You may overload this method to customize your minimap
-- @param mo
-- @param[type=Map] map
function _M:setupMinimapInfo(mo, map)
end

--- Adds a particles emitter following the entity
-- @param[type=Particles] ps
function _M:addParticles(ps)
	self.__particles[ps] = true
	if self.x and self.y and game.level and game.level.map then
		ps.x = self.x
		ps.y = self.y
		self:defineDisplayCallback()
	end
	return ps
end

--- Adds a particles emitter following the entity and duplicate it for the back
-- calls `addParticles`() twice internally
-- @param[type=table] def
-- @param[type=?table] args
-- @string[opt] shader
-- @return back `Particles`
-- @return front `Particles`
function _M:addParticles3D(def, args, shader)
	local args1, args2 = table.clone(args or {}), table.clone(args or {})
	args1.noup = 2
	args2.noup = 1
	local shader1, shader2 = nil, nil
	if shader then 
		shader1, shader2 = table.clone(shader), table.clone(shader)
		shader1.noup = 2
		shader2.noup = 1
	end
	local ps1 = Particles.new(def, 1, args1, shader1)
	ps1.toback = true
	local ps2 = Particles.new(def, 1, args2, shader2)

	self:addParticles(ps1)
	self:addParticles(ps2)

	return ps1, ps2
end

--- Removes a particles emitter following the entity
-- @param[type=Particles] ps
function _M:removeParticles(ps)
	if not ps then return end
	self.__particles[ps] = nil
	ps:dieDisplay()
	if self.x and self.y and game.level and game.level.map then
		ps.x = nil
		ps.y = nil
		self:defineDisplayCallback()
	end
end

--- Get the particle emitters of this entity
-- @param[type=string|bool] back "all" is a valid value
function _M:getParticlesList(back)
	local ps = {}
	for e, _ in pairs(self.__particles) do
		if (not back and not e.toback) or (back and e.toback) or (back == "all") then
			e:checkDisplay()
			ps[#ps+1] = e
		end
	end
	return ps
end

--- Removes the particles from the running threads but keep the data for later
function _M:closeParticles()
	for e, _ in pairs(self.__particles) do
		e:dieDisplay()
	end
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
	if self.add_displays then
		for i, add in ipairs(self.add_displays) do add:defineDisplayCallback() end
	end

	if not self._mo then return end
	if not next(self.__particles) then self._mo:displayCallback(nil) return end

	-- Cunning trick here!
	-- the callback we give to mo:displayCallback is a function that references self
	-- but self contains mo so it would create a cyclic reference and prevent GC'ing
	-- thus we store a reference to a weak table and put self into it
	-- this way when self dies the weak reference dies and does not prevent GC'ing
	local weak = setmetatable({[1]=self}, {__mode="v"})

	local ps = self:getParticlesList()
	self._mo:displayCallback(function(x, y, w, h)
		local self = weak[1]
		if not self or not self._mo then return end

		local e
		for i = 1, #ps do
			e = ps[i]
			e:checkDisplay()
			if e.ps:isAlive() then
				if game.level and game.level.map then e:shift(game.level.map, self._mo) end
				e.ps:toScreen(x + w / 2 + (e.dx or 0) * w, y + h / 2 + (e.dy or 0) * h, true, w / game.level.map.tile_w)
			else self:removeParticles(e)
			end
		end
		return true
	end)
end

--- Create the "map object" representing this entity
-- Do not touch unless you *KNOW* what you are doing.<br/>
-- You do *NOT* need this, this is used by the engine.Map class automatically.<br/>
-- *DO NOT TOUCH!!!*
-- @param[type=Tiles] tiles
-- @int idx
-- @return[1] nil
-- @return[2] self._mo
-- @return[2] self.z
-- @return[2] last_mo
function _M:makeMapObject(tiles, idx)
	if idx > 1 and not tiles.use_images then return nil end
	if idx > 1 then
		if not self.add_displays or not self.add_displays[idx-1] then return nil end
		return self.add_displays[idx-1]:makeMapObject(tiles, 1)
	else
		if self._mo and self._mo:isValid() then return self._mo, self.z, self._last_mo end
	end

	-- Texture
	local ok, btex, btexx, btexy, w, h, tex_x, tex_y = pcall(tiles.get, tiles, self.display, self.color_r, self.color_g, self.color_b, self.color_br, self.color_bg, self.color_bb, self.image, self._noalpha and 255, self.ascii_outline, true)

	local dy, dh = 0, 0
	if ok and self.auto_tall and h > w then dy = -1 dh = 1 end

	-- Create the map object with 1 + additional textures
	self._mo = core.map.newObject(self.uid,
		1 + (tiles.use_images and self.textures and #self.textures or 0),
		self:check("display_on_seen"),
		self:check("display_on_remember"),
		self:check("display_on_unknown"),
		self:check("display_x") or 0,
		(self:check("display_y") or 0) + dy,
		self:check("display_w") or 1,
		(self:check("display_h") or 1) + dh,
		self:check("display_scale") or 1
	)

	local last_mo = self._mo

	-- Setup tint
	self._mo:tint(self.tint_r or 1, self.tint_g or 1, self.tint_b or 1)

	-- Texture 0 is always the normal image/ascii tile
	-- we pcall it because some weird cases can not find a tile
	if ok then
		if self.anim then
			self._mo:texture(0, btex, false, btexx / self.anim.max, btexy, tex_x, tex_y)
			self._mo:setAnim(0, self.anim.max, self.anim.speed or 1, self.anim.loop or -1)
		else
			-- print("=======", self.image, btexx, btexy, te)
			self._mo:texture(0, btex, false, btexx, btexy, tex_x, tex_y)
		end
	end

	-- Additional MO chained to the same Z order
	if tiles.use_images and self.add_mos then
		local tex, texx, texy, pos_x, pos_y
		local cmo = self._mo
		for i = 1, #self.add_mos do
			local amo = self.add_mos[i]
			local dy, dh = amo.display_y or 0, amo.display_h or 1
			-- Create a simple additional chained MO
			if amo.image_alter == "sdm" then
				local _, bw, bh
				local oldrepo = tiles.repo
				tiles.repo = {}
				tex, _, _, bw, bh = tiles:get("", 0, 0, 0, 0, 0, 0, amo.image, false, false, false)
				tiles.repo = oldrepo
				local sdm_double = amo.sdm_double
				if sdm_double == "dynamic" then
					if bh > bw then sdm_double = false else sdm_double = true end
				end
				tex = tex:generateSDM(sdm_double)
				texx, texy = 1,1,nil,nil
			elseif amo.image then
				local w, h
				tex, texx, texy, w, h, pos_x, pos_y = tiles:get("", 0, 0, 0, 0, 0, 0, amo.image, false, false, true)
				if amo.auto_tall and h > w then dy = -1 dh = 2 end
			end
			local mo = core.map.newObject(self.uid, 1 + (tiles.use_images and amo.textures and #amo.textures or 0), false, false, false, amo.display_x or 0, dy, amo.display_w or 1, dh, amo.display_scale or 1)
			mo:texture(0, tex, false, texx, texy, pos_x, pos_y)
			if amo.particle then
				local args = amo.particle_args or {}
				local e = engine.Particles.new(amo.particle, 1, args)
				mo:displayCallback(function(x, y, w, h)
					e:checkDisplay()
					if e.ps:isAlive() then e.ps:toScreen(x + w / 2 + (args.x or 0), y + h / 2 + (args.y or 0), true, w / game.level.map.tile_w) end
					return true
				end)
			end

			-- Setup additional textures
			if tiles.use_images and amo.textures then
				for i = 1, #amo.textures do
					local t = amo.textures[i]
					if type(t) == "function" then local tex, is3d = t(amo, tiles); if tex then mo:texture(i, tex, is3d, 1, 1) tiles.texture_store[tex] = true end
					elseif type(t) == "table" then
						if t[1] == "image" then local tex = tiles:get('', 0, 0, 0, 0, 0, 0, t[2], nil, nil, nil, true); mo:texture(i, tex, false, 1, 1) tiles.texture_store[tex] = true
						end
					end
				end
			end

			-- Setup shader
			if tiles.use_images and core.shader.active() and amo.shader then
				local shad = Shader.new(amo.shader, amo.shader_args)
				if shad.shad then
					mo:shader(shad.shad)
					amo._shader = shad
				end
			end

			cmo:chain(mo)
			cmo = mo
			last_mo = mo
		end
	end

	-- Setup additional textures
	if tiles.use_images and self.textures then
		for i = 1, #self.textures do
			local t = self.textures[i]
			if type(t) == "function" then local tex, is3d = t(self, tiles); if tex then self._mo:texture(i, tex, is3d, 1, 1) tiles.texture_store[tex] = true end
			elseif type(t) == "table" then
				if t[1] == "image" then local tex = tiles:get('', 0, 0, 0, 0, 0, 0, t[2]); self._mo:texture(i, tex, false, 1, 1) tiles.texture_store[tex] = true
				end
			end
		end
	end

	self._mo, self.z, last_mo = self:alterMakeMapObject(tiles, self._mo, self.z, last_mo)

	-- Setup shader
	if tiles.use_images and core.shader.active() and self.shader then
		local shad = Shader.new(self.shader, self.shader_args)
		if shad.shad then
			self._mo:shader(shad.shad)
			self._shader = shad
		end
	end

	return self._mo, self.z, last_mo
end

--- Allows to alter the generated map objects  
-- Does nothing by default
-- @param[type=Tiles] tiles
-- @param mo Map Object
-- @param z
-- @param last_mo last Map Object
-- @return mo
-- @return z
-- @return last_mo
function _M:alterMakeMapObject(tiles, mo, z, last_mo)
	return mo, z, last_mo
end

--- Get all "map objects" representing this entity  
-- Do not touch unless you *KNOW* what you are doing.  
-- You do *NOT* need this, this is used by the engine.Map class automatically.  
-- *DO NOT TOUCH!!!*
-- @param[type=Tiles] tiles
-- @param mos map objects
-- @int z recursive index
function _M:getMapObjects(tiles, mos, z)
	local tgt = self
	if self.replace_display then tgt = self.replace_display end

	local i = -1
	local nextz = 0
	local mo, dz, lm
	local last_mo
	repeat
		i = i + 1
		mo, dz, lm = tgt:makeMapObject(tiles, 1+i)
		if mo then
			if i == 0 then self._mo = mo end
			if dz then mos[dz] = mo
			else mos[z + nextz] = mo nextz = nextz + 1 end
			last_mo = lm
		end
	until not mo
	self._last_mo = last_mo
	self:defineDisplayCallback()
end

--- Remove all Map objects for this entity
-- @param[type=boolean] no_invalidate don't invalidate the map object
function _M:removeAllMOs(no_invalidate)
	if self._mo and not no_invalidate then self._mo:invalidate() end
	self._mo = nil
	self._last_mo = nil

	if not self.add_displays then return end
	for i = 1, #self.add_displays do
		if self.add_displays[i]._mo then
			if not no_invalidate then self.add_displays[i]._mo:invalidate() end
			self.add_displays[i]._mo = nil
		end
	end
end

--- Setup movement animation for the entity
-- The entity is supposed to possess a correctly set x and y pair of fields - set to the current (new) position
-- @param oldx the coords from where the animation will seem to come from
-- @param oldy the coords from where the animation will seem to come from
-- @param speed the number of frames the animation lasts (frames are normalized to 30/sec no matter the actual FPS)
-- @param blur apply a motion blur effect of this number of frames
-- @param twitch_dir defaults to 8, the direction to do movement twitch
-- @param twitch defaults to 0, the amplitude of movement twitch
function _M:setMoveAnim(oldx, oldy, speed, blur, twitch_dir, twitch)
	if not self._mo then return end
	self._mo:setMoveAnim(oldx, oldy, self.x, self.y, speed, blur, twitch_dir, twitch)

	local add_displays = self.add_displays
	if self.replace_display then add_displays = self.replace_display.add_displays end

	if not add_displays then return end

	for i = 1, #add_displays do
		if add_displays[i]._mo then
			add_displays[i]._mo:setMoveAnim(oldx, oldy, self.x, self.y, speed, blur, twitch_dir, twitch)
		end
	end
end

--- Reset movement animation for the entity - removes any anim
function _M:resetMoveAnim()
	if not self._mo then return end
	self._mo:resetMoveAnim()

	if not self.add_displays then return end

	for i = 1, #self.add_displays do
		if self.add_displays[i]._mo then
			self.add_displays[i]._mo:resetMoveAnim()
		end
	end
end

--- Sets the flip state of MO and associated MOs
-- @param v passed to the map object's flipX()
function _M:MOflipX(v)
	if not self._mo then return end
	self._mo:flipX(v)
	self._flipx = v

	if not self.add_displays then return end

	for i = 1, #self.add_displays do
		if self.add_displays[i]._mo then
			self.add_displays[i]._mo:flipX(v)
		end
	end
end

--- Sets the flip state of MO and associated MOs
-- @param v passed to the map object's flipY()
function _M:MOflipY(v)
	if not self._mo then return end
	self._mo:flipY(v)
	self._flipy = v

	if not self.add_displays then return end

	for i = 1, #self.add_displays do
		if self.add_displays[i]._mo then
			self.add_displays[i]._mo:flipY(v)
		end
	end
end

--- Get the entity image as an sdl surface and texture for the given tiles and size
-- @param[type=Tiles] tiles a Tiles instance that will handle the tiles (usually pass it the current Map.tiles)
-- @param w the width
-- @param h the height
-- @return[1] nil if no texture
-- @return[2] the sdl surface
-- @return[2] the texture
function _M:getEntityFinalSurface(tiles, w, h)
	local id = w.."x"..h
	if _M.__mo_final_repo[self] and _M.__mo_final_repo[self][id] then return _M.__mo_final_repo[self][id].surface, _M.__mo_final_repo[self][id].tex end

	local Map = require "engine.Map"
	tiles = tiles or Map.tiles

	local mos = {}
	local list = {}
	self:getMapObjects(tiles, mos, 1)
	for i = 1, Map.zdepth do
		if mos[i] then list[#list+1] = mos[i] end
	end
	local tex = core.map.mapObjectsToTexture(w, h, unpack(list))
	if not tex then return nil end
	_M.__mo_final_repo[self] = _M.__mo_final_repo[self] or {}
	_M.__mo_final_repo[self][id] = {surface=tex:toSurface(), tex=tex}
	return _M.__mo_final_repo[self][id].surface, _M.__mo_final_repo[self][id].tex
end

--- Get the entity image as an sdl texture for the given tiles and size
-- @param[type=Tiles] tiles a Tiles instance that will handle the tiles (usually pass it the current Map.tiles)
-- @param w the width
-- @param h the height
-- @return[1] nil if no texture
-- @return[2] the texture
function _M:getEntityFinalTexture(tiles, w, h)
	local id = w.."x"..h
	if _M.__mo_final_repo[self] and _M.__mo_final_repo[self][id] then return _M.__mo_final_repo[self][id].tex end

	local Map = require "engine.Map"
	tiles = tiles or Map.tiles

	local mos = {}
	local list = {}
	self:getMapObjects(tiles, mos, 1)
	local listsize = #list
	for i = 1, Map.zdepth do
		if mos[i] then list[listsize+i] = mos[i] end
	end
	local tex = core.map.mapObjectsToTexture(w, h, unpack(list))
	if not tex then return nil end
	_M.__mo_final_repo[self] = _M.__mo_final_repo[self] or {}
	_M.__mo_final_repo[self][id] = {tex=tex}
	return _M.__mo_final_repo[self][id].tex
end

--- Get a string that will display in text the texture of this entity
-- @string[opt] tstr
function _M:getDisplayString(tstr)
	if tstr then
		if core.display.FBOActive() or true then
			return tstring{{"uid", self.uid}}
		else
			return tstring{}
		end
	else
		if core.display.FBOActive() or true then
			return "#UID:"..self.uid..":0#"
		else
			return ""
		end
	end
end

--- Displays an entity somewhere on screen, outside the map
-- @param[type=Tiles] tiles a Tiles instance that will handle the tiles (usually pass it the current Map.tiles, it will if this is null)
-- @int x where to display
-- @int y where to display
-- @int w the width
-- @int h the height
-- @param[type=?number] a the alpha setting
-- @param allow_cb
-- @param allow_shader
function _M:toScreen(tiles, x, y, w, h, a, allow_cb, allow_shader)
	local Map = require "engine.Map"
	tiles = tiles or Map.tiles

	local mos = {}
	local list = {}
	self:getMapObjects(tiles, mos, 1)
	for i = 1, Map.zdepth do
		if mos[i] then list[#list+1] = mos[i] end
	end
	core.map.mapObjectsToScreen(x, y, w, h, a, allow_cb, allow_shader, unpack(list))
end

--- Resolves an entity  
-- This is called when generating the final clones of an entity for use in a level.  
-- This can be used to make random enchants on objects, random properties on actors, ...  
-- by default this only looks for properties with a table value containing a __resolver field
-- @param[type=?table] t table defaults to self
-- @param[type=?boolean] last resolve last
-- @param[type=?boolean] on_entity
-- @param[type=?table] key_chain stores keys, defaults to {}
function _M:resolve(t, last, on_entity, key_chain)
	t = t or self
	key_chain = key_chain or {}

	-- First we grab the whole list to handle
	local list = {}
	for k, e in pairs(t) do
		if type(e) == "table" and e.__resolver and (not e.__resolve_last or last) then
			list[k] = e
		elseif type(e) == "table" and not e.__ATOMIC and not e.__CLASSNAME then
			list[k] = e
		end
	end

	-- Then we handle it, this is because resolvers can modify the list with their returns, or handlers, so we must make sure to not modify the list we are iterating over
	local r
	for k, e in pairs(list) do
		if type(e) == "table" and e.__resolver then
		end
		if type(e) == "table" and e.__resolver and (not e.__resolve_last or last) then
			if not resolvers.calc[e.__resolver] then error("missing resolver "..e.__resolver.." on entity "..tostring(t).." key "..table.concat(key_chain, ".")) end
			r = resolvers.calc[e.__resolver](e, on_entity or self, self, t, k, key_chain)
			t[k] = r
			if type(r) == "table" and r.__resolver and r.__resolve_instant and (not r.__resolve_last or last) then --handle a nested instant resolver immediately
				t[k] = resolvers.calc[r.__resolver](r, on_entity or self, self, t, k, key_chain)
			end
		elseif type(e) == "table" and not e.__ATOMIC and not e.__CLASSNAME then
			local key_chain = table.clone(key_chain)
			key_chain[#key_chain+1] = k
			self:resolve(e, last, on_entity, key_chain)
		end
	end

	-- Finish resolving stuff
	if on_entity then return end
	if t == self then
		if last then
			if self.resolveLevel then self:resolveLevel() end

			if self.unique and type(self.unique) == "boolean" then
				self.unique = self.name
			end
		else
			-- Handle IDed if possible
			if self.resolveIdentify then self:resolveIdentify() end
		end
	end
end

--- Print all resolvers registered
-- @param[type=?table] t defaults to self
function _M:printResolvers(t)
	for k, e in pairs(t or self) do
		if type(e) == "table" and e.__resolver then
			print(" * Resolver on entity", self.name, "::", e.__resolver, e.__resolve_last, " (with params) ", table.serialize(e, nil, true))
		end
	end
end

--- Call when the entity is actually added to a level/whatever
-- This helps ensuring uniqueness of uniques
function _M:added()
	if self.unique then
		game.uniques[self.__CLASSNAME.."/"..self.unique] = (game.uniques[self.__CLASSNAME.."/"..self.unique] or 0) + 1
		print("Added unique", self.__CLASSNAME.."/"..self.unique, "::", game.uniques[self.__CLASSNAME.."/"..self.unique])
	end
end

--- Call when the entity is actually removed from existence
-- This helps ensuring uniqueness of uniques.
-- This recursively removes inventories too, if you need anything special, overload this
function _M:removed()
	if self.inven then
		for _, inven in pairs(self.inven) do
			for i, o in ipairs(inven) do
				o:removed()
			end
		end
	end

	if game and game.hasEntity and game:hasEntity(self) then game:removeEntity(self) end

	if self.unique then
		game.uniques[self.__CLASSNAME.."/"..self.unique] = (game.uniques[self.__CLASSNAME.."/"..self.unique] or 0) - 1
		if game.uniques[self.__CLASSNAME.."/"..self.unique] <= 0 then game.uniques[self.__CLASSNAME.."/"..self.unique] = nil end
		print("Removed unique", self.__CLASSNAME.."/"..self.unique, "::", game.uniques[self.__CLASSNAME.."/"..self.unique])
	end
end

--- Check for an entity's property  
-- If not a function it returns it directly, otherwise it calls the function
-- with the extra parameters
-- @param prop the property name to check
-- @param[opt] ... the functions arguments
function _M:check(prop, ...)
	if type(self[prop]) == "function" then return self[prop](self, ...)
	else return self[prop]
	end
end

--- temporary values storage
_M.temporary_values_conf = {}

--- Computes a "temporary" value into a property
-- Example: You want to give an actor a boost to life_regen, but you do not want it to be permanent  
-- You cannot simply increase life_regen, so you use this method which will increase it AND
-- store the increase. it will return an "increase id" that can be passed to removeTemporaryValue()
-- to remove the effect.
-- @param[opt=tab|string] prop the property to affect.  This can be either a string or a table of strings, the latter allowing nested properties to be modified.
-- @param[opt=number|tab] v the value to add.  This should either be a number or a table of properties and numbers.
-- @param[type=boolean] noupdate if true the actual property is not changed and needs to be changed by the caller
-- @return an id that can be passed to removeTemporaryValue() to delete this value
function _M:addTemporaryValue(prop, v, noupdate)
	if not self.compute_vals then self.compute_vals = {n=0} end

	local t = self.compute_vals
	local id = t.n + 1
	while t[id] ~= nil do id = id + 1 end
	t[id] = v
	t.n = id

	-- Find the base, one removed from the last prop
	local initial_base, initial_prop
	if type(prop) == "table" then
		initial_base = self
		local idx = 1
		while idx < #prop do
			initial_base = initial_base[prop[idx]]
			idx = idx + 1
		end
		initial_prop = prop[idx]
	else
		initial_base = self
		initial_prop = prop
	end

	-- The recursive enclosure
	local recursive
	recursive = function(base, prop, v, method)
		method = self.temporary_values_conf[prop] or method
		if type(v) == "number" then
			-- Simple addition
			if method == "mult" then
				base[prop] = (base[prop] or 1) * v
			elseif method == "mult0" then
				base[prop] = (base[prop] or 1) * (1 + v)
			elseif method == "perc_inv" then
				v = v / 100
				local b = (base[prop] or 0) / 100
				b = 1 - (1 - b) * (1 - v)
				base[prop] = b * 100
			elseif method == "inv1" then
				v = util.bound(v, -0.999, 0.999)
				t[id] = v
				local b = (base[prop] or 1) - 1
				b = 1 - (1 - b) * (1 - v)
				base[prop] = b + 1
			elseif method == "highest" then
				base["__thighest_"..prop] = base["__thighest_"..prop] or {[-1] = base[prop]}
				base["__thighest_"..prop][id] = v
				base[prop] = table.max(base["__thighest_"..prop])
			elseif method == "lowest" then
				base["__tlowest_"..prop] = base["__tlowest_"..prop] or {[-1] = base[prop]}
				base["__tlowest_"..prop][id] = v
				base[prop] = table.min(base["__tlowest_"..prop])
			elseif method == "last" then
				base["__tlast_"..prop] = base["__tlast_"..prop] or {[-1] = base[prop]}
				local b = base["__tlast_"..prop]
				b[id] = v
				b = table.listify(b)
				table.sort(b, function(a, b) return a[1] > b[1] end)
				base[prop] = b[1] and b[1][2]
			else
if type(base[prop] or 0) ~= "number" or type(v) ~= "number" then
	print("ERROR: Attempting to add value", v, "property", prop, "to", base[prop]) table.print(base[prop]) table.print(v)
	print("Entity:", self) -- table.print(self)
	game.debug._debug_entity = self
end
				base[prop] = (base[prop] or 0) + v
			end
			self:onTemporaryValueChange(prop, v, base)
--			print("addTmpVal", base, prop, v, " :=: ", #t, id, method)
		elseif type(v) == "table" then
			for k, e in pairs(v) do
--				print("addTmpValTable", base[prop], k, e)
				base[prop] = base[prop] or {}
				recursive(base[prop], k, e, method)
			end
		elseif type(v) == "string" then
			-- Only last works on strings
			if true or method == "last" then
				base["__tlast_"..prop] = base["__tlast_"..prop] or {[-1] = base[prop]}
				local b = base["__tlast_"..prop]
				b[id] = v
				b = table.listify(b)
				table.sort(b, function(a, b) return a[1] > b[1] end)
				base[prop] = b[1] and b[1][2]
			else
				base[prop] = (base[prop] or 0) + v
			end
--			print("addTmpVal", base, prop, v, " :=: ", #t, id, method)
		else
			error("unsupported temporary value type: "..type(v).." :=: "..tostring(v).." (on key "..tostring(prop)..")")
		end
	end

	-- Update the base prop
	if not noupdate then
		recursive(initial_base, initial_prop, v, "add")
	end

	return id
end

--- Removes a temporary value, see addTemporaryValue()
-- @param[opt=tab|string] prop the property to affect
-- @int id the id of the increase to delete
-- @param[type=boolean] noupdate if true the actual property is not changed and needs to be changed by the caller
function _M:removeTemporaryValue(prop, id, noupdate)
	local oldval = self.compute_vals[id]
--	print("removeTempVal", prop, oldval, " :=: ", id)
	if not id then util.send_error_backtrace("error removing prop "..tostring(prop).." with id nil") return end
	self.compute_vals[id] = nil

	-- Find the base, one removed from the last prop
	local initial_base, initial_prop
	if type(prop) == "table" then
		initial_base = self
		local idx = 1
		while idx < #prop do
			initial_base = initial_base[prop[idx]]
			idx = idx + 1
		end
		initial_prop = prop[idx]
	else
		initial_base = self
		initial_prop = prop
	end

	-- The recursive enclosure
	local recursive
	recursive = function(base, prop, v, method)
		method = self.temporary_values_conf[prop] or method
		if type(v) == "number" then
			-- Simple addition
			if method == "mult" then
				base[prop] = base[prop] / v
			elseif method == "mult0" then
				base[prop] = base[prop] / (1 + v)
			elseif method == "perc_inv" then
				v = v / 100
				local b = base[prop] / 100
				b = 1 - (1 - b) / (1 - v)
				base[prop] = b * 100
			elseif method == "inv1" then
				local b = base[prop] - 1
				b = 1 - (1 - b) / (1 - v)
				base[prop] = b + 1
			elseif method == "highest" then
				base["__thighest_"..prop] = base["__thighest_"..prop] or {}
				base["__thighest_"..prop][id] = nil
				base[prop] = table.max(base["__thighest_"..prop])
				if not next(base["__thighest_"..prop]) then base["__thighest_"..prop] = nil end
			elseif method == "lowest" then
				base["__tlowest_"..prop] = base["__tlowest_"..prop] or {}
				base["__tlowest_"..prop][id] = nil
				base[prop] = table.min(base["__tlowest_"..prop])
				if not next(base["__tlowest_"..prop]) then base["__tlowest_"..prop] = nil end
			elseif method == "last" then
				base["__tlast_"..prop] = base["__tlast_"..prop] or {}
				local b = base["__tlast_"..prop]
				b[id] = nil
				b = table.listify(b)
				table.sort(b, function(a, b) return a[1] > b[1] end)
				base[prop] = b[1] and b[1][2]
				if not next(base["__tlast_"..prop]) then base["__tlast_"..prop] = nil end
			else
				if not base[prop] then util.send_error_backtrace("Error removing property "..tostring(prop).." with value "..tostring(v).." : base[prop] is nil") return end
				base[prop] = base[prop] - v
			end
			self:onTemporaryValueChange(prop, -v, base)
--			print("delTmpVal", prop, v, method)
		elseif type(v) == "table" then
			for k, e in pairs(v) do
				recursive(base[prop], k, e, method)
			end
		elseif type(v) == "string" then
			-- Only last works on strings
			if true or method == "last" then
				base["__tlast_"..prop] = base["__tlast_"..prop] or {}
				local b = base["__tlast_"..prop]
				b[id] = nil
				b = table.listify(b)
				table.sort(b, function(a, b) return a[1] > b[1] end)
				base[prop] = b[1] and b[1][2]
				if b[1] and b[1][1] == -1 then base["__tlast_"..prop][-1] = nil end
				if not next(base["__tlast_"..prop]) then base["__tlast_"..prop] = nil end
			else
				if not base[prop] then util.send_error_backtrace("Error removing property "..tostring(prop).." with value "..tostring(v).." : base[prop] is nil") return end
				base[prop] = base[prop] - v
			end
--			print("delTmpVal", prop, v, method)
		else
			if config.settings.cheat then
				if type(v) == "nil" then
					error("ERROR!!! unsupported temporary value type: "..type(v).." :=: "..tostring(v).." for "..tostring(prop))
				else
					error("unsupported temporary value type: "..type(v).." :=: "..tostring(v).." for "..tostring(prop))
				end
			end
		end
	end

	-- Update the base prop
	if not noupdate then
		recursive(initial_base, initial_prop, oldval, "add")
	end
end

--- Helper function to add temporary values
-- @param[type=table] t
-- @param k
-- @param v
function _M:tableTemporaryValue(t, k, v)
	t[#t+1] = {k, self:addTemporaryValue(k, v)}
end
--- Helper function to remove temporary values
-- @param[type=table] t
function _M:tableTemporaryValuesRemove(t)
	for i = 1, #t do
		self:removeTemporaryValue(t[i][1], t[i][2])
	end
end

--- Called when a temporary value changes (added or deleted)
-- This does nothing by default, you can overload it to react to changes
-- @param prop the property changing
-- @param v the value of the change
-- @param base the base table of prop
function _M:onTemporaryValueChange(prop, v, base)
end

--- Gets the change in an attribute/function based on changing another.
-- Measures the difference in result_attr from adding temporary values from and to to changed_attr.
-- @param changed_attr the attribute being changed
-- @param from the temp value added to changed_attr which we are starting from
-- @param to the temp value added to changed_attr which we are ending on
-- @param result_attr the result we are measuring the difference in
-- @param ... arguments to pass to result_attr if it is a function
-- @return the difference
-- @return the from result
-- @return the to result
function _M:getAttrChange(changed_attr, from, to, result_attr, ...)
	local temp = self:addTemporaryValue(changed_attr, from)
	local from_result = util.getval(self[result_attr], self, ...)
	self:removeTemporaryValue(changed_attr, temp)

	temp = self:addTemporaryValue(changed_attr, to)
	local to_result = util.getval(self[result_attr], self, ...)
	self:removeTemporaryValue(changed_attr, temp)

	return to_result - from_result, from_result, to_result
end

--- Increases/decreases an attribute
-- The attributes are just actor properties, but this ensures they are numbers and not booleans
-- thus making them compatible with temporary values system
-- @param prop the property to use
-- @param[opt] v the value to add, if nil the function returns
-- @param[opt] fix forces the value to v, does not add
-- @return nil if v was specified
-- @return nil if property doesn't exist
-- @return If v isn't specified then it returns the current value if it exists and isn't 0
function _M:attr(prop, v, fix)
	if v then
		if fix then self[prop] = v
		else self[prop] = (self[prop] or 0) + v
		end
	else
		if self[prop] and self[prop] ~= 0 then
			return self[prop]
		else
			return nil
		end
	end
end

--- Loads a list of entities from a definition file
-- @string file the file to load from
-- @param[type=?boolean] no_default if true then no default values will be assigned
-- @param[type=?table] res the table to load into, defaults to a new one
-- @func[opt] mod a function to which will be passed each entity as they are created. Can be used to adjust some values on the fly
-- @param[type=?table] loaded a table of already loaded files
-- @usage MyEntityClass:loadList("/data/my_entities_def.lua")
function _M:loadList(file, no_default, res, mod, loaded)
	local Zone = require "engine.Zone"

	if type(file) == "table" then
		res = res or {}
		for i, f in ipairs(file) do
			self:loadList(f, no_default, res, mod, loaded)
		end
		return res
	end

	no_default = no_default and true or false
	res = res or {}

	local f, err = nil, nil
	if entities_load_functions[file] and entities_load_functions[file][no_default] then
		print("Loading entities file from memory", file)
		f = entities_load_functions[file][no_default]
	elseif fs.exists(file) then
		f, err = loadfile(file)
		print("Loading entities file from file", file)
		entities_load_functions[file] = entities_load_functions[file] or {}
		entities_load_functions[file][no_default] = f
	else
		-- No data
		print("Loading entities file from file", file, "which does not exists!")
		f = function() end
	end
	if err then error(err) end

	loaded = loaded or {}
	if res.ignore_loaded and loaded[file] then return res end
	loaded[file] = true

	local newenv newenv = {
		currentZone = Zone:getCurrentLoadingZone(),
		class = self,
		loaded = loaded,
		resolvers = resolvers,
		DamageType = require "engine.DamageType",
		entity_mod = mod,
		loading_list = res,
		ignoreLoaded = function(v) res.ignore_loaded = v end,
		rarity = function(add, mult) add = add or 0; mult = mult or 1; return function(e) if e.rarity then e.rarity = math.ceil(e.rarity * mult + add) end end end,
		switchRarity = function(name) return function(e) if e.rarity then e[name], e.rarity = e.rarity, nil end end end,
		newEntity = function(t)
			-- Do we inherit things ?
			if t.base then
				local base = res[t.base]
				if not base and res.import_source then base = res.import_source[t.base] end

				t = importBase(t, base)
			end

			local e = newenv.class.new(t, no_default)
			if type(mod) == "function" then mod(e) end

			res[#res+1] = e
			if t.define_as then res[t.define_as] = e end
		end,
		importEntity = function(t)
			local e = t:cloneFull()
			if mod then mod(e) end
			res[#res+1] = e
			if t.define_as then res[t.define_as] = e end
		end,
		load = function(f, new_mod)
			self:loadList(f, no_default, res, new_mod or mod, loaded)
		end,
		loadList = function(f, new_mod, list, loaded)
			return self:loadList(f, no_default, list, new_mod or mod, loaded)
		end,
	}
	setfenv(f, setmetatable(newenv, {__index=_G}))
	f()
	setfenv(f, {})
	newenv.currentZone = nil

	self:triggerHook{"Entity:loadList", file=file, no_default=no_default, res=res, mod=mod, loaded=loaded}

	res.__loaded_files = loaded

	return res
end

--- Return the kind of the entity
-- @return "entity"
function _M:getEntityKind()
	return "entity"
end

--- Putting this here to avoid errors, not sure if appropriate
-- @string type_str
-- @return false
function _M:checkClassification(type_str)
	return false
end
