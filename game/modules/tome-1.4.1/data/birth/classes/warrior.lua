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

local Particles = require "engine.Particles"

newBirthDescriptor{
	type = "class",
	name = "Warrior",
	desc = {
		"Warriors train in all aspects of physical combat. They can be juggernauts of destruction wielding two-handed greatswords, or massive iron-clad protectors with gleaming shields.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Berserker = "allow",
			Bulwark = "allow",
			Archer= "allow",
			Brawler = "allow",
			["Arcane Blade"] = "allow",
		},
	},
	copy = {
		max_life = 120,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Berserker",
	desc = {
		"A Berserker wields huge two-handed weapons of destruction, bringing pain and death to his foes as he cleaves them in two.",
		"A Berserker usually forfeits all ideas of self-defense to concentrate on what he does best: killing things.",
		"Their most important stats are: Strength and Constitution",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +1 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +3",
	},
	power_source = {technique=true},
	stats = { str=5, con=3, dex=1, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-defense"]={false, -0.1},
		["technique/2hweapon-assault"]={true, 0.3},
		["technique/strength-of-the-berserker"]={true, 0.3},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["technique/bloodthirst"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_WARSHOUT_BERSERKER] = 1,
		[ActorTalents.T_STUNNING_BLOW_ASSAULT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 3,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Bulwark",
	desc = {
		"A Bulwark specializes in weapon and shield combat, rarely leaving the cover of her many protective techniques.",
		"A good Bulwark is able to withstand terrible attacks from all sides, protected by her shield, and when the time comes lash out at her foes with incredible strength.",
		"Their most important stats are: Strength and Dexterity",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +2 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true},
	stats = { str=5, con=2, dex=2, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/battle-tactics"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_SHIELD_WALL] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 2,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
	},
	copy = {
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archer",
	desc = {
		"Archers are dexterous ranged fighters, able to pin their foes to the ground and rain down a carpet of arrows on them.",
		"Skilled archers can fire special shots that pierce, cripple or pin their foes.",
		"Archers can become good with either longbows or slings.",
		"Their most important stats are: Dexterity and Strength (when using bows) or Cunning (when using slings)",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +5 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, technique_ranged=true},
	stats = { dex=5, str=2, cun=2, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={true, 0.3},
		["technique/archery-sling"]={true, 0.3},
		["technique/archery-excellence"]={false, 0.3},
		["technique/combat-techniques-active"]={false, -0.1},
		["technique/combat-techniques-passive"]={true, -0.1},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0},
		["cunning/trapping"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, 0.2, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_FLARE] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_BOW_MASTERY] = 1,
		[ActorTalents.T_SLING_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="shot", name="pouch of iron shots", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Arcane Blade",
	desc = {
		"The Arcane Blade is a warrior who has been touched by the gift of magic.",
		"Their use of magic is innate and not really studied; as such they do not naturally regenerate mana and must use external means of recharging.",
		"They can cast spells from a limited selection but have the unique capacity to 'channel' their attack spells through their melee attacks.",
		"They are adept with two-handed weapons, for the sheer destruction they can bring.",
		"Their most important stats are: Strength, Cunning and Magic",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +3 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	stats = { mag=3, str=3, cun=3},
	talents_types = {
		["spell/fire"]={true, 0.2},
		["spell/air"]={true, 0.2},
		["spell/earth"]={true, 0.2},
		["spell/conveyance"]={true, 0.2},
		["spell/aegis"]={true, 0.1},
		["spell/enhancement"]={true, 0.2},
		--["technique/battle-tactics"]={false, 0.2},
		["technique/superiority"]={false, 0.2},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-techniques-passive"]={false, 0.1},
		["technique/combat-training"]={true, 0.1},
		["technique/magical-combat"]={true, 0.3},
		["technique/shield-offense"]={false, 0},
		["technique/2hweapon-assault"]={false, 0},
		["technique/dualweapon-attack"]={false, 0},
		["cunning/survival"]={true, 0.1},
		["cunning/dirty"]={true, 0.2},
	},
	unlockable_talents_types = {
		["spell/stone"]={false, 0.1, "mage_geomancer"},
	},
	birth_example_particles = {
		function(actor) if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = actor:attachementSpot("hand1", true) if h1x then actor:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = actor:attachementSpot("hand2", true) if h2x then actor:addParticles(Particles.new("shader_shield", 1, {img="fireball", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end end,
		function(actor) if core.shader.active(4) then
			local slow = rng.percent(50)
			local h1x, h1y = actor:attachementSpot("hand1", true) if h1x then actor:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h1x, y=h1y-0.1}, {type="flamehands", time_factor=slow and 700 or 1000})) end
			local h2x, h2y = actor:attachementSpot("hand2", true) if h2x then actor:addParticles(Particles.new("shader_shield", 1, {img="lightningwings", a=0.7, size_factor=0.4, x=h2x, y=h2y-0.1}, {type="flamehands", time_factor=not slow and 700 or 1000})) end
		end end,
	},
	talents = {
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_ARCANE_COMBAT] = 1,
		[ActorTalents.T_DIRTY_FIGHTING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 100,
--		talent_cd_reduction={[ActorTalents.T_FLAME]=-3, [ActorTalents.T_LIGHTNING]=-3, [ActorTalents.T_EARTHEN_MISSILES]=-3, },
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Brawler",
	locked = function() return profile.mod.allow_build.warrior_brawler end,
	locked_desc = "Though you may fight alone against many, destined to fight till you die, still you do not relent. In a ring of blood you learn that a pair of fists can face the world.",
	desc = {
		"The ravages of the Spellblaze stretched armies thin and left many unprotected. Not everyone could afford the luxury of a weapon.",
		"Without steel or iron, poor communities of all races turned to the strength of their own bodies for defense against the darkness.",
		"Whether a pit-fighter, a boxer, or just an amateur practitioner, the Brawler's skills are still handy today.",
		"Many of the Brawler's abilities will earn combo points which they can use on finishing moves that will have added effect.",
		"The unarmed fighting styles the Brawler uses rely on maneuverability and having both hands available. As such, they cannot make use of their training wearing massive armour or while a weapon or shield is equipped.",
		"Their most important stats are: Strength, Dexterity, and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true},
	stats = { str=3, dex=3, cun=3},
	talents_types = {
		["cunning/dirty"]={false, 0},
		["cunning/tactical"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/combat-training"]={true, 0.1},
		["technique/field-control"]={true, 0},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-techniques-passive"]={true, 0.1},
		["technique/pugilism"]={true, 0.3},
		["technique/finishing-moves"]={true, 0.3},
		["technique/grappling"]={false, 0.3},
		["technique/unarmed-discipline"]={false, 0.3},
		["technique/unarmed-training"]={true, 0.3},
		["technique/conditioning"]={true, 0.1},
		["technique/mobility"]={true, 0.2},
	},
	talents = {
		[ActorTalents.T_UPPERCUT] = 1,
		[ActorTalents.T_DOUBLE_STRIKE] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_UNARMED_MASTERY] = 1, -- early game is absolutely stupid without this
	},
	copy = {
		resolvers.equipbirth{ id=true,
			{type="armor", subtype="hands", name="iron gauntlets", autoreq=true, ego_chance=-1000, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true,
			{type="armor", subtype="hands", name="rough leather gloves", ego_chance=-1000, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}



