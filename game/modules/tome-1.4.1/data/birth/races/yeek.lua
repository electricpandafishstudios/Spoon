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
--                       Yeeks                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Yeek",
	locked = function() return profile.mod.allow_build.yeek end,
	locked_desc = "One race, one mind, one way. Our oppression shall end, and we shall inherit Eyal. Do not presume we are weak - our way is true, and only those who help us shall see our strength.",
	desc = {
		"Yeeks are a mysterious race of small humanoids native to the tropical island of Rel.",
		"Their body is covered with white fur and their disproportionate heads give them a ridiculous look.",
		"Although they are now nearly unheard of in Maj'Eyal, they spent many thousand years as secret slaves to the Halfling nation of Nargol.",
		"They gained their freedom during the Age of Pyre and have since then followed 'The Way' - a unity of minds enforced by their powerful psionics.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			Yeek = "allow",
		},
	},
	copy = {
		faction = "the-way",
		type = "humanoid", subtype="yeek",
		size_category = 2,
		default_wilderness = {"playerpop", "yeek"},
		starting_zone = "town-irkkk",
		starting_quest = "start-yeek",
		starting_intro = "yeek",
		blood_color = colors.BLUE,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={physical=true}, dur=4, power=14}),
		resolvers.inventory({id=true, transmo=false, alter=function(o) o.inscription_data.cooldown=12 o.inscription_data.heal=50 end, {type="scroll", subtype="infusion", name="healing infusion", ego_chance=-1000, ego_chance=-1000}}),
	},
	game_state = {
		start_tier1_skip = 4,
	},
	random_escort_possibilities = { {"tier1.1", 1, 2}, {"tier1.2", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
	moddable_attachement_spots = "race_yeek", moddable_attachement_spots_sexless=true,

	cosmetic_unlock = {
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
--                       Yeeks                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Yeek",
	locked = function() return profile.mod.allow_build.yeek end,
	locked_desc = "One race, one mind, one way. Our oppression shall end, and we shall inherit Eyal. Do not presume we are weak - our way is true, and only those who help us shall see our strength.",
	desc = {
		"Yeeks are a mysterious race native to the tropical island of Rel.",
		"Although they are now nearly unheard of in Maj'Eyal, they spent many centuries as secret slaves to the Halfling nation of Nargol.",
		"They gained their freedom during the Age of Pyre and have since then followed 'The Way' - a unity of minds enforced by their powerful psionics.",
		"They possess the #GOLD#Dominant Will#WHITE# talent which allows them to temporarily subvert the mind of a lesser creature. When the effect ends, the creature dies.",
		"While Yeeks are not amphibians, they still have an affinity for water, allowing them to survive longer without breathing.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * -3 Strength, -2 Dexterity, -5 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +6 Willpower, +4 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 7",
		"#GOLD#Experience penalty:#LIGHT_BLUE# -15%",
		"#GOLD#Confusion resistance:#LIGHT_BLUE# 35%",
	},
	inc_stats = { str=-3, con=-5, cun=4, wil=6, mag=0, dex=-2 },
	talents_types = { ["race/yeek"]={true, 0} },
	talents = {
		[ActorTalents.T_YEEK_WILL]=1,
		[ActorTalents.T_YEEK_ID]=1,
	},
	copy = {
		life_rating=7,
		confusion_immune = 0.35,
		max_air = 200,
		moddable_tile = "yeek",
		random_name_def = "yeek_#sex#",
	},
	experience = 0.85,
}
