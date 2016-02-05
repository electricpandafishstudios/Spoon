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

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Halfling",
	desc = {
		"Halflings are a race of very short stature, rarely exceeding four feet in height.",
		"They are like humans in that they can do just about anything they set their minds to, yet they excel at ordering and studying things.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the Human kingdoms during the Age of Allure.",
		"Halflings are agile, lucky, and resilient but lacking in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Halfling = "allow",
		},
		subclass = {
			-- Only human, elves, halflings and undeads are supposed to be archmages
			Archmage = "allow",
		},
	},
	copy = {
		faction = "allied-kingdoms",
		type = "humanoid", subtype="halfling",
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "trollmire",
		starting_quest = "start-allied",
		starting_intro = "halfling",
		size_category = 2,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=12 o.inscription_data.heal=50 end, {type="scroll", subtype="infusion", name="healing infusion", ego_chance=-1000, ego_chance=-1000}}),
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },

	moddable_attachement_spots = "race_halfling",
	cosmetic_unlock = {
		cosmetic_race_human_redhead = {
			{name="Redhead [donator only]", donator=true, on_actor=function(actor) if actor.moddable_tile then actor.moddable_tile_base = "base_redhead_01.png" end end},
		},
		cosmetic_bikini =  {
			{name="Bikini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Bikini if not o then print("No bikini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_BIKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Female" end},
			{name="Mankini [donator only]", donator=true, on_actor=function(actor, birther, last)
				if not last then local o = birther.obj_list_by_name.Mankini if not o then print("No mankini found!") return end actor:getInven(actor.INVEN_BODY)[1] = o:cloneFull()
				else actor:registerOnBirthForceWear("FUN_MANKINI") end
			end, check=function(birth) return birth.descriptors_by_type.sex == "Male" end},
		},
	},
}

---------------------------------------------------------
--                      Halflings                      --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Halfling",
	desc = {
		"Halflings are a race of very short stature, rarely exceeding four feet in height.",
		"They are like humans in that they can do just about anything they set their minds to, yet they excel at ordering and studying things.",
		"Halfling armies have brought many kingdoms to their knees and they kept a balance of power with the Human kingdoms during the Age of Allure.",
		"They possess the #GOLD#Luck of the Little Folk#WHITE# which allows them to increase their critical strike chance and saves for a few turns.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * -3 Strength, +3 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
		"#LIGHT_BLUE# * +5 Luck",
		"#GOLD#Life per level:#LIGHT_BLUE# 12",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 20%",
	},
	inc_stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.20,
	talents_types = { ["race/halfling"]={true, 0} },
	talents = {
		[ActorTalents.T_HALFLING_LUCK]=1,
	},
	copy = {
		moddable_tile = "halfling_#sex#",
		random_name_def = "halfling_#sex#",
		life_rating = 12,
	},
}
