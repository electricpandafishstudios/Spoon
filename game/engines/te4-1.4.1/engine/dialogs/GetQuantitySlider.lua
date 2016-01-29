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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local NumberSlider = require "engine.ui.NumberSlider"

--- Generic popup for getting quantity
-- @classmod engine.dialogs.GetQuantity
module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, prompt, default, min, max, step, action)
	self.action = action

	Dialog.init(self, title or "Quantity", 320, 110)

	local c_box = NumberSlider.new{title=prompt and (prompt..": ") or "", value=default or 0, max=max, min=min, step=step, size=400, fct=function() self:okclick() end}
	self.c_box = c_box
	local ok = require("engine.ui.Button").new{text="Accept", fct=function() self:okclick() end}
	local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancelclick() end}

	self:loadUI{
		{left=0, top=0, padding_h=10, ui=c_box},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	self:setFocus(c_box)
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:okclick()
	self.qty = self.c_box.value
	if self.qty then
		game:unregisterDialog(self)
		self.action(self.qty)
	else
		Dialog:simplePopup("Error", "Enter a quantity.")
	end
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
