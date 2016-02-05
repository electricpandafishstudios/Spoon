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

local Map = require "engine.Map"

newTalent{
	name = "Dirty Fighting",
	type = {"cunning/dirty", 1},
	points = 5,
	random_ego = "attack",
	cooldown = 12,
	stamina = 10,
	tactical = { DISABLE = {stun = 2}, ATTACK = {weapon = 0.5} },
	require = cuns_req1,
	requires_target = true,
	range = 1,
	is_melee = true,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.2, 0.7) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			if target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, t.getDuration(self, t), {apply_power=self:combatAttack()})
			end
			if not target:hasEffect(target.EFF_STUNNED) then
				self:logCombat(target, "#Target# resists the stun and #Source# quickly regains its footing!")
				self.energy.value = self.energy.value + game.energy_to_act * self:getSpeed("weapon")
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[You hit your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits, the target is stunned for %d turns.
		Stun chance increase with your Accuracy.
		If you fail to stun the target (or if it shrugs off the effect), you quickly recover; the use of the skill does not take a turn.]]):
		format(100 * damage, duration)
	end,
}

newTalent{
	name = "Backstab",
	type = {"cunning/dirty", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	-- called by _M:physicalCrit in mod.class.interface.Combat.la
	getCriticalChance = function(self, t) return self:combatTalentScale(t, 15, 50, 0.75) end,
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	getStunChance = function(self, t) return self:combatTalentLimit(t, 100, 3, 15) end, -- Limit < 100%
	info = function(self, t)
		return ([[Your quick wit gives you a big advantage against stunned targets; all your hits will have a %d%% greater chance of being critical.
		Also, your melee critical strikes have %d%% chance to stun the target for 3 turns.]]):
		format(t.getCriticalChance(self, t), t.getStunChance(self, t))
	end,
}
newTalent{
	name = "Switch Place",
	type = {"cunning/dirty", 3},
	points = 5,
	random_ego = "defensive",
	cooldown = 10,
	stamina = 15,
	require = cuns_req3,
	requires_target = true,
	tactical = { DISABLE = 2 },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	on_pre_use = function(self, t)
		if self:attr("never_move") then return false end
		return true
	end,
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local tx, ty, sx, sy = target.x, target.y, self.x, self.y
		local hitted = self:attackTarget(target, nil, 0, true)

		if hitted and not self.dead and tx == target.x and ty == target.y then
			if not self:canMove(tx,ty,true) or not target:canMove(sx,sy,true) then
				self:logCombat(target, "Terrain prevents #Source# from switching places with #Target#.")
				return true
			end
			self:setEffect(self.EFF_EVASION, t.getDuration(self, t), {chance=50})
			-- Displace
			if not target.dead then
				self:move(tx, ty, true)
				target:move(sx, sy, true)
			end
		end

		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Using a series of tricks and maneuvers, you switch places with your target.
		Switching places will confuse your foes, granting you Evasion (50%%) for %d turns.
		While switching places, your weapon(s) will connect with the target; this will not do weapon damage, but on hit effects of the weapons can trigger.]]):
		format(duration)
	end,
}

newTalent{
	name = "Cripple",
	type = {"cunning/dirty", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 25,
	stamina = 20,
	require = cuns_req4,
	requires_target = true,
	tactical = { DISABLE = 2, ATTACK = {weapon = 2} },
	is_melee = true,
	range = 1,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t)} end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1, 1.9) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 4, 8)) end,
	getSpeedPenalty = function(self, t) return self:combatLimit(self:combatTalentStatDamage(t, "cun", 5, 50), 100, 20, 0, 55.7, 35.7) end, -- Limit < 100%
	speed = "weapon",
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end
		local hitted = self:attackTarget(target, nil, t.getDamage(self, t), true)

		if hitted then
			local speed = t.getSpeedPenalty(self, t) / 100
			target:setEffect(target.EFF_CRIPPLE, t.getDuration(self, t), {speed=speed, apply_power=self:combatAttack()})
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local speedpen = t.getSpeedPenalty(self, t)
		return ([[You hit your target, doing %d%% damage. If your attack connects, the target is crippled for %d turns, losing %d%% melee, spellcasting and mind speed.
		The chance to land the status improves with Accuracy, and the status power improves with Cunning.]]):
		format(100 * damage, duration, speedpen)
	end,
}
