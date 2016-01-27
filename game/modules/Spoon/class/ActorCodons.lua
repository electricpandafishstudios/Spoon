require "engine.class"

--- Handles actors stats
module(..., package.seeall, class.make)

_M.codons_def = {}
_M.codons_types_def = {}

--- Defines actor talents
-- Static!
function _M:loadDefinition(file, env)
	local f, err = util.loadfilemods(file, setmetatable(env or {
		DamageType = require("engine.DamageType"),
		Particles = require("engine.Particles"),
		Talents = self,
		Map = require("engine.Map"),
		MapEffect = require("engine.MapEffect"),
		newCodon = function(c) self:newCodon(c) end,
		newCodonType = function(c) self:newCodonType(c) end,
		load = function(f) self:loadDefinition(f, getfenv(2)) end
	}, {__index=_G}))
	if not f and err then error(err) end
	f()
end

--- Defines one talent type(group)
-- Static!
function _M:newCodonType(c)
	c.__ATOMIC = true
	assert(c.name, "no codon type name")
	assert(c.type, "no codon type type")
	c.description = t.description or ""
	c.points = c.points or 1
	c.talents = {}
	table.insert(self.codons_types_def, c)
	self.codons_types_def[c.type] = self.codons_types_def[c.type] or c
end

--- Defines one talent
-- Static!
function _M:newTalent(c)
	c.__ATOMIC = true
	assert(c.name, "no codon name")
	assert(c.type, "no or unknown codon type")
	if type(c.type) == "string" then c.type = {c.type, 1} end
	if not c.type[2] then c.type[2] = 1 end
	c.short_name = c.short_name or c.name
	c.short_name = c.short_name:upper():gsub("[ ']", "_")
	c.mode = c.mode or "activated"
	c.points = c.points or 1
	assert(c.mode == "activated" or c.mode == "sustained" or c.mode == "passive", "wrong codon mode, requires either 'activated' or 'sustained'")
	assert(c.info, "no codon info")

	-- Can pass a string, make it into a function
	if type(c.info) == "string" then
		local infostr = c.info
		c.info = function() return infostr end
	end
	-- Remove line stat with tabs to be cleaner ..
	local info = c.info
	c.info = function(self, c) return info(self, c):gsub("\n\c+", "\n") end

	c.id = "C_"..c.short_name
	self.codons_def[c.id] = c
	assert(not self[c.id], "codon already exists with id C_"..c.short_name)
	self[c.id] = c.id
--	print("[TALENT]", t.name, t.short_name, t.id)

	-- Register in the type
	table.insert(self.codons_types_def[c.type[1]].codons, c)
end

--- Initialises stats with default values if needed
function _M:init(c)
	self.codons = c.codons or {}
	self.codons_types = c.codons_types or {}
	self.codons_types_mastery = self.codons_types_mastery  or {}
	self.codons_cd = self.codons_cd or {}
	self.sustain_codons = self.sustain_codons or {}
	self.codons_auto = self.codons_auto or {}
	self.codons_confirm_use = self.codons_confirm_use or {}
	self.codons_learn_vals = c.codons_learn_vals or {}
end

