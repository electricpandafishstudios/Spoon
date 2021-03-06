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
	name = "Fiery Hands",
	type = {"spell/enhancement",1},
	require = spells_req1,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	getFireDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 40) end,
	getFireDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 14) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		local ret = {
			particle = particle,
			dam = self:addTemporaryValue("melee_project", {[DamageType.FIRE] = t.getFireDamage(self, t)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = t.getFireDamageIncrease(self, t)}),
			sta = self:addTemporaryValue("stamina_regen_on_hit", self:getTalentLevel(t) / 3),
		}
		if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = self:attachementSpot("hand1", true) if h1x then ret.particle1 = self:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = self:attachementSpot("hand2", true) if h2x then ret.particle2 = self:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		self:removeTemporaryValue("stamina_regen_on_hit", p.sta)
		return true
	end,
	info = function(self, t)
		local firedamage = t.getFireDamage(self, t)
		local firedamageinc = t.getFireDamageIncrease(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of fire, dealing %0.2f fire damage per melee attack and increasing all fire damage dealt by %d%%.
		Each hit will also regenerate %0.2f stamina.
		The effects will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.FIRE, firedamage), firedamageinc, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Earthen Barrier",
	type = {"spell/enhancement", 2},
	points = 5,
	random_ego = "utility",
	cooldown = 25,
	mana = 45,
	require = spells_req2,
	range = 10,
	tactical = { DEFEND = 2 },
	getPhysicalReduction = function(self, t) return self:combatTalentSpellDamage(t, 10, 60) end,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_EARTHEN_BARRIER, 10, {power=t.getPhysicalReduction(self, t)})
		return true
	end,
	info = function(self, t)
		local reduction = t.getPhysicalReduction(self, t)
		return ([[Hardens your skin with the power of earth, reducing physical damage taken by %d%% for 10 turns.
		Damage reduction will increase with your Spellpower.]]):
		format(reduction)
	end,
}

newTalent{
	name = "Shock Hands",
	type = {"spell/enhancement", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	getIceDamage = function(self, t) return self:combatTalentSpellDamage(t, 3, 20) end,
	getIceDamageIncrease = function(self, t) return self:combatTalentSpellDamage(t, 5, 14) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/lightning")
		local ret = {
			dam = self:addTemporaryValue("melee_project", {[DamageType.LIGHTNING_DAZE] = t.getIceDamage(self, t)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.LIGHTNING] = t.getIceDamageIncrease(self, t)}),
			man = self:addTemporaryValue("mana_regen_on_hit", self:getTalentLevel(t) / 3),
		}
		if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = self:attachementSpot("hand1", true) if h1x then ret.particle1 = self:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = self:attachementSpot("hand2", true) if h2x then ret.particle2 = self:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end
		return ret
	end,
	deactivate = function(self, t, p)
		if p.particle1 then self:removeParticles(p.particle1) end
		if p.particle2 then self:removeParticles(p.particle2) end
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		self:removeTemporaryValue("mana_regen_on_hit", p.man)
		return true
	end,
	info = function(self, t)
		local icedamage = t.getIceDamage(self, t)
		local icedamageinc = t.getIceDamageIncrease(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of lightning, dealing %d lightning damage with a chance to daze (25%%) per melee attack and increasing all lightning damage dealt by %d%%.
		Each hit will also regenerate %0.2f mana.
		The effects will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.LIGHTNING, icedamage), icedamageinc, self:getTalentLevel(t) / 3)
	end,
}

newTalent{
	name = "Inner Power",
	type = {"spell/enhancement", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 75,
	tactical = { BUFF = 2 },
	getStatIncrease = function(self, t) return math.floor(self:combatTalentSpellDamage(t, 2, 10)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = t.getStatIncrease(self, t)
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		local statinc = t.getStatIncrease(self, t)
		return ([[You concentrate on your inner self, increasing all your stats by %d.
		The stat increase will improve with your Spellpower.]]):
		format(statinc)
	end,
}
