-- TE4 - T-Engine 4
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

--- Handles autoleveling schemes  
-- Used mainly for NPCS, although it could also be used for player allies
-- or players themselves for lazy players/modules
-- @classmod engine.Autolevel
module(..., package.seeall, class.make)

_M.schemes = {}

--- Register Scheme for use with actors
-- @param[type=table] t your scheme definition
-- @usage registerScheme({ name = "warrior", levelup = function(self) self:learnStats{ self.STAT_STR, self.STAT_STR, self.STAT_DEX } end})
function _M:registerScheme(t)
	assert(t.name, "no autolevel name")
	assert(t.levelup, "no autolevel levelup function")
	_M.schemes[t.name] = t
end

--- Triggers the autolevel function defined with registerScheme for the specified actor
-- @param[type=Actor] actor
function _M:autoLevel(actor)
	if not actor.autolevel then return end
	assert(_M.schemes[actor.autolevel], "no autoleveling scheme "..actor.autolevel)

	_M.schemes[actor.autolevel].levelup(actor)
end
