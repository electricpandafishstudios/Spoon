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

return {
	name = "Last Hope",
	level_range = {15, 35},
	level_scheme = "player",
	actor_adjust_level = function(zone, level, e) return zone.base_level + e:getRankLevelAdjust() + level.level-1 + rng.range(-1,2) end,
	update_base_level_on_enter = true,
	max_level = 1,
	width = 196, height = 80,
	decay = {300, 800, only={object=true}, no_respawn=true},
	persistent = "zone",
	all_remembered = true,
	all_lited = true,
	day_night = true,
	ambient_music = {"For the king and the country!.ogg", "weather/town_large_base.ogg"},
	allow_respec = "limited",

	min_material_level = function() if game.state.stores_restock >= 3 then return 3 elseif game.state.stores_restock >= 2 then return 2 else return 1 end end,
	max_material_level = function() if game.state.stores_restock >= 3 then return 4 elseif game.state.stores_restock >= 2 then return 3 else return 2 end end,
	store_levels_by_restock = { 20, 35, 45 },

	generator =  {
		map = {
			class = "engine.generator.map.Static",
			map = "towns/last-hope",
		},
		actor = {
			class = "mod.class.generator.actor.Random",
			nb_npc = {10, 10},
		},
		object = {
			class = "engine.generator.object.Random",
			nb_object = {0, 0},
		},
	},

	post_process = function(level)
		game.state:makeAmbientSounds(level, {
			town_large={ chance=250, volume_mod=1, pitch=1, random_pos={rad=10}, files={"ambient/town/town_large1","ambient/town/town_large2","ambient/town/town_large3"}},
		})
	end,
}
