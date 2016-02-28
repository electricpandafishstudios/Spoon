require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.aminos_def = {}
_M.aminos_types_def = {}

--- Defines actor aminos
-- Static!
function _M:loadDefinition(file, env)
	local f, err = util.loadfilemods(file, setmetatable(env or {
		DamageType = require("engine.DamageType"),
		Particles = require("engine.Particles"),
		Aminos = self,
		Map = require("engine.Map"),
		MapEffect = require("engine.MapEffect"),
		newAmino = function(a) self:newAmino(a) end,
		newAminoType = function(a) self:newAminoType(a) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
	}, {__index=_G}))
	if not f and err then error(err) end
	f()
end

--- Defines one Amino type(group)
-- Static!
function _M:newAminoType(a)
	a.__ATOMIC = true
	assert(a.name, "no amino type name")
	assert(a.type, "no amino type type")
	a.description = a.description or ""
	--a.points = a.points or 1
	a.aminos = {}
	table.insert(self.aminos_types_def, a)
	self.aminos_types_def[a.type] = self.aminos_types_def[a.type] or a
end

--- Defines one talent
-- Static!
function _M:newAmino(a)
	a.__ATOMIC = true
	assert(a.name, "no amino name")
	assert(a.type, "no or unknown amino type")
	if type(a.type) == "string" then a.type = {a.type, 1} end
	if not a.type[2] then a.type[2] = 1 end
	a.short_name = a.short_name or a.name
	a.short_name = a.short_name:upper():gsub("[ ']", "_")
	--a.mode = a.mode or "aativated"
	--a.points = a.points or 1
	--assert(a.mode == "activated" or c.mode == "sustained" or c.mode == "passive", "wrong amino mode, requires either 'activated' or 'sustained'")
	assert(a.info, "no amino info")

	-- Can pass a string, make it into a function
	if type(a.info) == "string" then
		local infostr = a.info
		a.info = function() return infostr end
	end
	-- Remove line stat with tabs to be cleaner ..
	local info = a.info
	a.info = function(self, a) return info(self, a):gsub("\n\t+", "\n") end

	a.id = "A_"..a.short_name	
	self.aminos_def[a.id] = a
	assert(not self[a.id], "amino already exists with id A_"..a.short_name)
	self[a.id] = a.id
--	print("[Amino]", a.name, a.short_name, a.id)

	-- Register in the type
	table.insert(self.aminos_types_def[a.type[1]].aminos, a)
end

function _M:gainAmino(a_id)
	local a = _M.aminos_def[a_id]
	local l = table.getn(self.aminos)

	--self.aminos[a_id] = (self.aminos[t_id] or 0) + 1
	self.aminos[l + 1] = a_id

	if a.on_gain then
		a.on_gain(self, a)
		--loaal ret = a.on_gain(self, a)
		--if ret then
			--if ret == true then ret = {} end
			--self.aminos_learn_vals[l+1] = self.aminos_learn_vals[l+1] or {}
			--self.aminos_learn_vals[l+1][self.aminos[l+1]] = ret
		--end
	end
end
--- Initialises stats with default values if needed

--- Return the full description of an Amino
-- You may overload it to add more data (like power usage, ...)
function _M:getAminoFullDescription(a)
	return tstring{a.info(self, a), true}
end

--- Returns display name
function _M:getAminoDisplayName(a)
	if not a.display_name then return a.name end
	if type(a.display_name) == "function" then return a.display_name(self, a) end
	return a.display_name
end
function _M:init(a)
	self.aminos = a.aminos or {}
	self.aminos_types = a.aminos_types or {}
	--self.aminos_types_mastery = self.aminos_types_mastery  or {}
	--self.aminos_ad = self.aminos_ad or {}
	--self.sustain_aminos = self.sustain_aminos or {}
	--self.aminos_auto = self.aminos_auto or {}
	--self.aminos_aonfirm_use = self.aminos_aonfirm_use or {}
	--self.aminos_learn_vals = a.aminos_learn_vals or {}
end
