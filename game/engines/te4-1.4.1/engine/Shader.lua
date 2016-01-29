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

--- Handles a particles system
-- Used by engine.Map
-- @classmod engine.Shader
module(..., package.seeall, class.make)

_M.verts = {}
_M.frags = {}
_M.progsperm = {}
_M.progs = {}
_M.progsreset = {}

loadNoDelay = true

function core.shader.allow(kind)
	return config.settings['shaders_kind_'..kind] and core.shader.active(4)
end

function _M:cleanup()
	local time = os.time()
	local todel = {}
	for name, s in pairs(self.progs) do
		if s.dieat < time then todel[name] = true end
	end
	for name, _ in pairs(todel) do
		self.progs[name] = nil
		self.progsreset[name] = nil
		print("Deleting temp shader", name)
	end
end

--- Make a shader
function _M:init(name, args)
	self.args = args or {}
	self.name = name
	self.totalname = self:makeTotalName()
--	print("[SHADER] making shader from", name, " into ", self.totalname)

	if args and args.require_shader then
		if not core.shader.active(4) or not core.shader.active(args.require_shader) then return end
	end
	if args and args.require_kind then
		if not core.shader.active(4) or not core.shader.allow(args.require_kind) then return end
	end

	if not core.shader.active() then return end

	if not self.args.delay_load then
		self:loaded()
	else
		self.old_meta = getmetatable(self)
		setmetatable(self, {__index=function(t, k)
			if k ~= "shad" then return _M[k] end
			print("Shader delayed load running for", t.name)
			t:loaded()
			setmetatable(t, t.old_meta)
			t.old_meta = nil
			return t.shad
		end})
	end
end

function _M:makeTotalName(add)
	local str = {}
	local args = self.args
	if add then args = table.clone(add) table.merge(args, self.args) end
	for k, v in pairs(args) do
		if type(v) == "function" then v = v(self) end
		if type(v) == "number" then
			str[#str+1] = k.."="..tostring(v)
		elseif type(v) == "table" then
			if v.texture then
				if v.is3d then str[#str+1] = k.."=tex3d("..v.texture..")"
				else str[#str+1] = k.."=tex3d("..v.texture..")" end
			elseif #v == 2 then
				str[#str+1] = k.."=vec2("..v[1]..","..v[2]..")"
			elseif #v == 3 then
				str[#str+1] = k.."=vec3("..v[1]..","..v[2]..","..v[3]..")"
			elseif #v == 4 then
				str[#str+1] = k.."=vec4("..v[1]..","..v[2]..","..v[3]..","..v[4]..")"
			end
		end
	end
	table.sort(str)
	return self.name.."["..table.concat(str,",").."]"
end

--- Serialization
function _M:save()
	return class.save(self, {
		shad = true,
	})
end

function _M:getFragment(name)
	if not name then return nil end
	if self.frags[name] then return self.frags[name] end
	local f = fs.open("/data/gfx/shaders/"..name..".frag", "r")
	local code = {}
	while true do
		local l = f:read(1)
		if not l then break end
		code[#code+1] = l
	end
	f:close()
	self.frags[name] = core.shader.newShader(table.concat(code))
	print("[SHADER] created fragment shader from /data/gfx/shaders/"..name..".frag")
	return self.frags[name]
end

function _M:getVertex(name)
	if not name then return nil end
	if self.verts[name] then return self.verts[name] end
	local f = fs.open("/data/gfx/shaders/"..name..".vert", "r")
	local code = {}
	while true do
		local l = f:read(1)
		if not l then break end
		code[#code+1] = l
	end
	f:close()
	self.verts[name] = core.shader.newShader(table.concat(code), true)
	print("[SHADER] created vertex shader from /data/gfx/shaders/"..name..".vert")
	return self.verts[name]
end

function _M:createProgram(def)
	local shad = core.shader.newProgram()
	if not shad then return nil end
	if def.vert then shad:attach(self:getVertex(def.vert)) end
	if def.frag then shad:attach(self:getFragment(def.frag)) end
	if not shad:compile() then return nil end
	return shad
end

function _M:loaded()
	if _M.progsperm[self.totalname] then
		-- print("[SHADER] using permcached shader "..self.totalname)
		self.shad = _M.progsperm[self.totalname]
	elseif _M.progs[self.totalname] then
		-- print("[SHADER] using cached shader "..self.totalname)
		self.shad = _M.progs[self.totalname].shad
		_M.progs[self.totalname].dieat = os.time() + 60*4
		if _M.progsreset[self.totalname] and self.shad then
			self.shad = self.shad:clone()
		end
	else
		print("[SHADER] Loading from /data/gfx/shaders/"..self.name..".lua")
		local f, err = loadfile("/data/gfx/shaders/"..self.name..".lua")
		if not f and err then error(err) end
		setfenv(f, setmetatable(self.args or {}, {__index=_G}))
		local def = f()

		if def.require_shader then
			if not core.shader.active(def.require_shader) then return end
		end
		if def.require_kind then
			if not core.shader.allow(def.require_kind) then return end
		end

		print("[SHADER] Loaded shader with totalname", self.totalname)

		if not _M.progs[self.totalname] then
			_M.progs[self.totalname] = {shad=self:createProgram(def), dieat=(os.time() + 60*4)}
		else
			_M.progs[self.totalname].dieat = (os.time() + 60*4)
		end

		if def.resetargs then
			_M.progsreset[self.totalname] = def.resetargs
		end

		self.shad = _M.progs[self.totalname].shad
		if self.shad then
			for k, v in pairs(def.args) do
				self:setUniform(k, v)
			end
		end

		if def.permanent then _M.progsperm[self.totalname] = self.shad end
	end

	if self.shad and _M.progsreset[self.totalname] then
		self.shad:resetClean()
		for k, v in pairs(_M.progsreset[self.totalname]) do
			self:setResetUniform(k, v(self))
		end
	end
end

function _M:setUniform(k, v)
	if type(v) == "number" then
--		print("[SHADER] setting param", k, v)
		self.shad:paramNumber(k, v)
	elseif type(v) == "table" then
		if v.texture then
--			print("[SHADER] setting texture param", k, v.texture)
			self.shad:paramTexture(k, v.texture, v.is3d)
		elseif #v == 2 then
--			print("[SHADER] setting vec2 param", k, v[1], v[2])
			self.shad:paramNumber2(k, v[1], v[2])
		elseif #v == 3 then
--			print("[SHADER] setting vec3 param", k, v[1], v[2], v[3])
			self.shad:paramNumber3(k, v[1], v[2], v[3])
		elseif #v == 4 then
--			print("[SHADER] setting vec4 param", k, v[1], v[2], v[3], v[4])
			self.shad:paramNumber4(k, v[1], v[2], v[3], v[4])
		end
	end
end

function _M:setResetUniform(k, v)
	if type(v) == "number" then
		print("[SHADER] setting reset param", k, v)
		self.shad:resetParamNumber(k, v)
	elseif type(v) == "table" then
		if v.texture then
--			print("[SHADER] setting texture param", k, v.texture)
			self.shad:resetParamTexture(k, v.texture, v.is3d)
		elseif #v == 2 then
--			print("[SHADER] setting vec2 param", k, v[1], v[2])
			self.shad:resetParamNumber2(k, v[1], v[2])
		elseif #v == 3 then
--			print("[SHADER] setting vec3 param", k, v[1], v[2], v[3])
			self.shad:resetParamNumber3(k, v[1], v[2], v[3])
		elseif #v == 4 then
--			print("[SHADER] setting vec4 param", k, v[1], v[2], v[3], v[4])
			self.shad:resetParamNumber4(k, v[1], v[2], v[3], v[4])
		end
	end
end

----------------------------------------------------------------------------
-- Default shaders
----------------------------------------------------------------------------
default = {}

function _M:setDefault(kind, name, args)
	default[kind] = _M.new(name, args)
end
