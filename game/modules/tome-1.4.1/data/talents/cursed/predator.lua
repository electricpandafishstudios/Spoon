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

newTalent{
	name = "Mark Prey",
	type = {"cursed/predator", 1},
	require = cursed_lev_req1,
	points = 5,
	tactical = { ATTACK = 3 },
	cooldown = 5,
	range = 10,
	no_energy = true,
	getMaxKillExperience = function(self, t)
		local total = 0

		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_ANATOMY)
		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_OUTMANEUVER)
		if t then total = total + self:getTalentLevelRaw(t) end
		local t = self:getTalentFromId(self.T_MIMIC)
		if t then total = total + self:getTalentLevelRaw(t) end

		return self:combatLimit(total, 0, 19.5, 1, 10, 20) --  Limit > 0
	end,
	getSubtypeDamageChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 0.15
	end,
	getTypeDamageChange = function(self, t)
		return math.pow(self:getTalentLevel(t), 0.5) * 0.065
	end,
	getHateBonus = function(self, t) return self:combatTalentScale(t, 3, 10, "log")	end,
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not target or not self:canProject(tg, x, y) then return nil end

		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff and eff.type == target.type and eff.subtype == target.subtype then
			return false
		end
		if eff then self:removeEffect(self.EFF_PREDATOR, true, true) end
		self:setEffect(self.EFF_PREDATOR, 1, { type=target.type, subtype=target.subtype, killExperience = 0, subtypeKills = 0, typeKills = 0 })

		return true
	end,
	on_unlearn = function(self, t)
		if not self:knowTalent(t) then
			local ef = self.tempeffect_def.EFF_PREDATOR
			ef.no_remove = false
			self:removeEffect(self.EFF_PREDATOR)
			ef.no_remove = true
		end
	end,
	info = function(self, t)
		local maxKillExperience = t.getMaxKillExperience(self, t)
		local subtypeDamageChange = t.getSubtypeDamageChange(self, t)
		local typeDamageChange = t.getTypeDamageChange(self, t)
		local hateDesc = ""
		if self:knowTalent(self.T_HATE_POOL) then
			local hateBonus = t.getHateBonus(self, t)
			hateDesc = (" Every kill of a marked sub-type gives you an additional +%d hate regardless of your current effectiveness."):format(hateBonus)
		end
		return ([[Mark a single opponent as your prey, gaining bonuses against the targeted creature's type and sub-type. Bonuses scale with the experience you gain from killing your marked type (+0.25 kill experience) and marked sub-type (+1 kill experience). At %0.1f kill experience, you reach 100%% effectiveness. Combat attacks against the marked type gain +%d%% damage, while those against the marked sub-type gain +%d%% damage.%s
		Each point in Mark Prey reduces the kill experience required to reach 100%% effectivess as a Predator.]]):format(maxKillExperience, typeDamageChange * 100, subtypeDamageChange * 100, hateDesc)
	end,
}

newTalent{
	name = "Anatomy",
	type = {"cursed/predator", 2},
	mode = "passive",
	require = cursed_lev_req2,
	points = 5,
	getSubtypeAttackChange = function(self, t) return self:combatTalentScale(t, 5, 15.4, 0.75) end,
	getTypeAttackChange = function(self, t) return self:combatTalentScale(t, 2, 6.2, 0.75) end,
	getSubtypeStunChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 3.1, 1, 6.93, 2.23) end, -- Limit < 100%
	on_learn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	on_unlearn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	info = function(self, t)
		local subtypeAttackChange = t.getSubtypeAttackChange(self, t)
		local typeAttackChange = t.getTypeAttackChange(self, t)
		local subtypeStunChance = t.getSubtypeStunChance(self, t)
		return ([[Your knowledge of your prey allows you to strike with extra precision. Attacks against the marked type gain +%d Accuracy, while those against the marked sub-type gain +%d Accuracy. Melee hits also gain a %0.1f%% chance to stun the marked sub-type for 3 turns with each attack.
		Each point in Anatomy reduces the kill experience required to reach 100%% effectivess as a Predator.]]):format(typeAttackChange, subtypeAttackChange, subtypeStunChance)
	end,
}

newTalent{
	name = "Outmaneuver",
	type = {"cursed/predator", 3},
	mode = "passive",
	require = cursed_lev_req3,
	points = 5,
	getDuration = function(self, t)
		return 10
	end,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	getSubtypeChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 10, 1, 22.3, 2.23) end, -- Limit <100%
	getTypeChance = function(self, t) return self:combatLimit(self:getTalentLevel(t)^0.5, 100, 4, 1, 8.94, 2.23) end, -- Limit <100%
	getPhysicalResistChange = function(self, t) return -self:combatLimit(self:getTalentLevel(t)^0.5, 100, 8, 1, 17.9, 2.23) end, -- Limit <100%
	getStatReduction = function(self, t)
		return math.floor(math.sqrt(self:getTalentLevel(t)) * 4.3)
	end,
	on_learn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	on_unlearn = function(self, t)
		local eff = self:hasEffect(self.EFF_PREDATOR)
		if eff then
			self.tempeffect_def[self.EFF_PREDATOR].updateEffect(self, eff)
		end
	end,
	info = function(self, t)
		local subtypeChance = t.getSubtypeChance(self, t)
		local typeChance = t.getTypeChance(self, t)
		local physicalResistChange = t.getPhysicalResistChange(self, t)
		local statReduction = t.getStatReduction(self, t)
		local duration = t.getDuration(self, t)
		return ([[Each melee hit gives you a chance to outmaneuver your marked prey, lowering their physical resistance by %d%% and reducing their highest statistic by %d. Subject to your effectiveness against the marked prey, there is a %0.1f%% chance to outmaneuver your marked type and a %0.1f%% maximum chance to outmaneuver your marked sub-type. The effects last for %d turns, and can accumulate.
		Each point in Outmaneuver reduces the kill experience required to reach 100%% effectivess as a Predator.]]):format(-physicalResistChange, statReduction, typeChance, subtypeChance, duration)
	end,
}

newTalent{
	name = "Mimic",
	type = {"cursed/predator", 4},
	mode = "passive",
	require = cursed_lev_req4,
	points = 5,
	getMaxIncrease = function(self, t) return self:combatTalentScale(t, 7, 21.6, 0.75) end,
	on_learn = function(self, t)
		self:removeEffect(self.EFF_MIMIC, true, true)
	end,
	on_unlearn = function(self, t)
		self:removeEffect(self.EFF_MIMIC, true, true)
	end,
	info = function(self, t)
		local maxIncrease = t.getMaxIncrease(self, t)
		return ([[You learn to mimic the strengths of your prey. Killing a marked sub-type raises your stats to match the strengths of the victim (up to a maximum of %d total points, subject to your current effectiveness). The effect lasts indefinitely, but only the effects of the latest kill will be applied.
		Each point in Mimic reduces the kill experience required to reach 100%% effectivess as a Predator.]]):format(maxIncrease)
	end,
}
