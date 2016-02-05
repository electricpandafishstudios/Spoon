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
	name = "Vitality",
	type = {"technique/conditioning", 1},
	require = techs_con_req1,
	mode = "passive",
	points = 5,
	cooldown = 15,
	getHealValues = function(self, t)  --base, fraction of max life
		return (self.life_rating or 10) + self:combatTalentStatDamage(t, "con", 2, 20), self:combatTalentLimit(t, 0.3, 0.07, 0.16)
	end,
	getWoundReduction = function(self, t) return self:combatTalentLimit(t, 1, 0.17, 0.5) end, -- Limit <100%
	getDuration = function(self, t) return 8 end,
	do_vitality_recovery = function(self, t)
		if self:isTalentCoolingDown(t) then return end
		local baseheal, percent = t.getHealValues(self, t)
		self:setEffect(self.EFF_RECOVERY, t.getDuration(self, t), {power = baseheal, pct = percent / t.getDuration(self, t)})
		self:startTalentCooldown(t)
	end,
	info = function(self, t)
		local wounds = t.getWoundReduction(self, t) * 100
		local baseheal, healpct = t.getHealValues(self, t)
		local duration = t.getDuration(self, t)
		local totalheal = baseheal + self.max_life*healpct/duration
		return ([[You recover faster from poisons, diseases and wounds, reducing the duration of all such effects by %d%%.  
		Additionally, when your life falls below 50%%, you heal for a base %0.1f health plus %0.1f%% of your maximum life (currently %0.1f total) each turn for %d turns. This effect can only happen once every %d turns.
		The base healing scales with your Constitution.]]):
		format(wounds, baseheal, healpct/duration*100, totalheal, duration, self:getTalentCooldown(t))
	end,
}

newTalent{
	name = "Unflinching Resolve",
	type = {"technique/conditioning", 2},
	require = techs_con_req2,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return self:combatStatLimit("con", 1, .28, .745)*self:combatTalentLimit(t,100, 28,74.8) end, -- Limit < 100%
	callbackOnActBase = function(self, t)
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			if e.status == "detrimental" then
				if e.subtype.stun then 
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.blind and self:getTalentLevel(t) >=2 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.confusion and self:getTalentLevel(t) >=3 then
					effs[#effs+1] = {"effect", eff_id}
				elseif e.subtype.pin and self:getTalentLevel(t) >=4 then
					effs[#effs+1] = {"effect", eff_id}
				elseif (e.subtype.slow or e.subtype.wound) and self:getTalentLevel(t) >=5 then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end
		
		if #effs > 0 then
			local eff = rng.tableRemove(effs)
			if eff[1] == "effect" and rng.percent(t.getChance(self, t)) then
				self:removeEffect(eff[2])
				game.logSeen(self, "#ORCHID#%s has recovered!#LAST#", self.name:capitalize())
			end
		end
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You've learned to recover quickly from effects that would disable you. Each turn, you have a %d%% chance to recover from a single stun effect.
		At talent level 2 you may also recover from blindness, at level 3 confusion, level 4 pins, and level 5 slows and wounds. 
		Only one effect may be recovered from each turn, and the chance to recover from an effect scales with your Constitution.]]):
		format(chance)
	end,
}

newTalent{
	name = "Daunting Presence",
	type = {"technique/conditioning", 3},
	require = techs_con_req3,
	points = 5,
	mode = "sustained",
	sustain_stamina = 20,
	cooldown = 8,
	tactical = { DEFEND = 2, DISABLE = 1, },
	range = 0,
	getRadius = function(self, t) return math.ceil(self:combatTalentScale(t, 0.25, 2.3)) end,
	getPenalty = function(self, t) return self:combatTalentPhysicalDamage(t, 5, 36) end,
	getMinimumLife = function(self, t)
		return self.max_life * self:combatTalentLimit(t, 0.1, 0.45, 0.25) -- Limit > 10% life
	end,
	on_pre_use = function(self, t, silent) if t.getMinimumLife(self, t) > self.life then if not silent then game.logPlayer(self, "You are too injured to use this talent.") end return false end return true end,
	do_daunting_presence = function(self, t)
		local tg = {type="ball", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		self:project(tg, self.x, self.y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if target then
				if target:canBe("fear") then
					target:setEffect(target.EFF_INTIMIDATED, 4, {apply_power=self:combatAttackStr(), power=t.getPenalty(self, t), no_ct_effect=true})
					game.level.map:particleEmitter(target.x, target.y, 1, "flame")
				else
					game.logSeen(target, "%s is not intimidated!", target.name:capitalize())
				end
			end
		end)
	end,
	callbackOnActBase = function(self, t)
		if self.life < t.getMinimumLife(self, t) then
			self:forceUseTalent(t.id, {ignore_energy=true})
		end
	end,
	activate = function(self, t)
		local ret = {	}
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local penalty = t.getPenalty(self, t)
		local min_life = t.getMinimumLife(self, t)
		return ([[Enemies are intimidated by how composed you remain under fire.  When you take more then 5%% of your maximum life in a single hit, all enemies in a radius of %d will be intimidated, reducing their Physical Power, Mindpower, and Spellpower by %d for 4 turns.
		If your health drops below %d, you'll be unable to maintain your daunting presence, and the sustain will deactivate.  
		The power of the intimidation effect improves with your Physical power, and it's chance to affect your enemies improves with your Strength.]]):
		format(radius, penalty, min_life)
	end,
}

newTalent{
	name = "Adrenaline Surge", -- no stamina cost; it's main purpose is to give the player an alternative means of using stamina based talents
	type = {"technique/conditioning", 4},
	require = techs_con_req4,
	points = 5,
	cooldown = 24,
	tactical = { STAMINA = 1, BUFF = 2 },
	getAttackPower = function(self, t) return self:combatTalentStatDamage(t, "con", 5, 25) end,
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 24, 3, 7)) end, -- Limit < 24
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_ADRENALINE_SURGE, t.getDuration(self, t), {power = t.getAttackPower(self, t)})
		return true
	end,
	info = function(self, t)
		local attack_power = t.getAttackPower(self, t)
		local duration = t.getDuration(self, t)
		return ([[You release a surge of adrenaline that increases your Physical Power by %d for %d turns. While the effect is active, you may continue to fight beyond the point of exhaustion.
		Your stamina based sustains will not be disabled if your stamina reaches zero, and you may continue to use stamina based talents while at zero stamina at the cost of life.
		The Physical Power increase will scale with your Constitution.
		Using this talent does not take a turn.]]):
		format(attack_power, duration)
	end,
}
