-- ToME - Tales of Maj'Eyal
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
require "engine.Trap"
require "engine.interface.ActorProject"
require "engine.interface.ObjectIdentify"
require "mod.class.interface.Combat"
local Faction = require "engine.Faction"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(
	engine.Trap,
	engine.interface.ObjectIdentify,
	engine.interface.ActorProject,
	mod.class.interface.Combat
))

_M.projectile_class = "mod.class.Projectile"

function _M:init(t, no_default)
	self.faction = "enemies"
	engine.Trap.init(self, t, no_default)
	engine.interface.ObjectIdentify.init(self, t)
	engine.interface.ActorProject.init(self, t)
	self.str = self.str or 10
	self.mag = self.mag or 10
	self.dex = self.dex or 10
	self.wil = self.wil or 10
end

function _M:altered(t)
	if t then for k, v in pairs(t) do self[k] = v end end
	self.__SAVEINSTEAD = nil
	self.__nice_tile_base = nil
	self.nice_tiler = nil
end

function _M:combatPhysicalpower() return mod.class.interface.Combat:rescaleCombatStats(self.str) end
function _M:combatSpellpower() return mod.class.interface.Combat:rescaleCombatStats(self.mag) end
function _M:combatMindpower() return mod.class.interface.Combat:rescaleCombatStats(self.wil) end
function _M:combatAttack() return mod.class.interface.Combat:rescaleCombatStats(self.dex) end

function _M:resolveSource()
	if self.summoner_gain_exp and self.summoner then
		return self.summoner:resolveSource()
	else
		return self
	end
end

-- Gets the full name of the trap
function _M:getName()
	local name = self.name or "trap"
	if not self:isIdentified() and self:getUnidentifiedName() then name = self:getUnidentifiedName() end
	if self.summoner and self.summoner.name then
		return self.summoner.name:capitalize().."'s "..name
	else
		return name
	end
end

--- Set the known status for the given actor and make its tile remembered on the map for the player
function _M:setKnown(actor, v, x, y)
	self.known_by[actor] = v
	if actor.player and x and y and game.level.map(x, y, engine.Map.TRAP) == self then
		game.level.map(x, y, engine.Map.TERRAIN).always_remember = true
	end
end

-- Returns a tooltip for the trap
function _M:tooltip()
	if self:knownBy(game.player) then
		local res = tstring{{"uid", self.uid}, self:getName()}
		if self.temporary then res:add(true, ("#LIGHT_GREEN#%d turns#WHITE#"):format(self.temporary)) end
		if self.is_store then res:add(true, {"font","italic"}, "<Store>", {"font","normal"}) end

		if self.store_faction then
			local factcolor, factstate, factlevel = "#ANTIQUE_WHITE#", "neutral", Faction:factionReaction(self.store_faction, game.player.faction)
			if factlevel < 0 then factcolor, factstate = "#LIGHT_RED#", "hostile"
			elseif factlevel > 0 then factcolor, factstate = "#LIGHT_GREEN#", "friendly"
			end
			if Faction.factions[self.store_faction] then res:add(true, "Faction: ") res:merge(factcolor:toTString()) res:add(("%s (%s, %d)"):format(Faction.factions[self.store_faction].name, factstate, factlevel), {"color", "WHITE"}, true) end
		end		

		if config.settings.cheat then
			res:add(true, "UID: "..self.uid, true, "Detect: "..self.detect_power, true, "Disarm: "..self.disarm_power)
		end
		return res
	end
end

--- What is our reaction toward the target
-- See Faction:factionReaction()
function _M:reactionToward(target)
	return Faction:factionReaction(self.faction, target.faction)
end

--- Can we disarm this trap?
function _M:canDisarm(x, y, who)
	if not engine.Trap.canDisarm(self, x, y, who) then return false end

	-- do we know how to disarm?
	if (who:getTalentLevel(who.T_HEIGHTENED_SENSES) >= 3) or who:attr("can_disarm") then
		local th = who:getTalentFromId(who.T_HEIGHTENED_SENSES)
		local power = th.trapPower(who, th) + (who:attr("disarm_bonus") or 0)
		if who:checkHit(power, self.disarm_power) and (not self.faction or who:reactionToward(self) < 0) then
			return true
		end
	end

	-- False by default
	return false
end

--- Called when disarmed
function _M:onDisarm(x, y, who)
	self:check("disarmed", x, y, who)
end

--- Called when triggered
function _M:canTrigger(x, y, who, no_random)
	-- used for wormholes and any other self-buff style of trap
	if self.beneficial_trap and self.faction and who.reactionToward and who:reactionToward(self) >= 0 then return true end
	
	if rng.percent(5) and not self.beneficial_trap then
		if self:knownBy(who) then game.logPlayer(who, "You somehow avoid the trap (%s).", self:getName()) end
		return false
	end
	if who:attr("avoid_traps") then return false end
	if self.pressure_trap and who:attr("avoid_pressure_traps") then return false end
	if self.faction and who.reactionToward and who:reactionToward(self) >= 0 then return false end
	if not no_random and who.trap_avoidance and rng.percent(who.trap_avoidance) then
		if self:knownBy(who) then game.logPlayer(who, "You carefully avoid the trap (%s).", self:getName()) end
		return false
	end
	if who:attr("walk_sun_path") and game.level then
		for i, e in ipairs(game.level.map.effects) do if e.damtype == DamageType.SUN_PATH and e.grids[x] and e.grids[x][y] then return false end end
	end
	return true
end

--- Trigger the trap
function _M:trigger(x, y, who)
	engine.Trap.trigger(self, x, y, who)
	if who.runStop then who:runStop("trap") end
end

--- Identify the trap
function _M:identify(id)
	self.identified = id
end
