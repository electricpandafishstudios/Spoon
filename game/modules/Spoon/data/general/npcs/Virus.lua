-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_Virus",
	type = "humanoid", subtype = "virus",
	display = "v", color=colors.WHITE,
	desc = [[Ugly and green!]],

	ai = "dumb_talented_simple", ai_state = { talent_in=3, },
	stats = {},
	drops = { amt = 1, U = 22.5, C = 7.5, A = 7.5, G= 7.5},
	combat_armor = 0,
}

newEntity{ base = "BASE_NPC_Virus",
	name = "virus", color=colors.GREEN,
	level_range = {1, 4}, exp_worth = 0,
	rarity = 4,
	max_life = 2,
	combat = { dam=1 },
}

