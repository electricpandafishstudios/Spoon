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

require "engine.class"
local Shader = require "engine.Shader"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local FontPackage = require "engine.FontPackage"
local Quest = require "engine.Quest"

module(..., package.seeall, class.inherit(Dialog))

local statuses = {
	[-1] = "#LIGHT_GREEN#New#LAST# Quest!",
	[Quest.PENDING] = "Quest #AQUAMARINE#Updated!",
	[Quest.COMPLETED] = "Quest #LIGHT_GREEN#Completed!",
	[Quest.DONE] = "Quest #LIGHT_GREEN#Done!",
	[Quest.FAILED] = "Quest #CIMSON#Failed!",
}

function _M:init(quest, status)
	self.quest = quest
	self.ui = "quest"
	Dialog.init(self, "", 666, 150)

	self.blight = self:getUITexture("ui/dialogframe_backglow.png")

	local f, fs = FontPackage:getFont("bold")
	local quest = Textzone.new{auto_width=true, auto_height=true, text="#ANTIQUE_WHITE#Quest: #AQUAMARINE#"..self.quest.name, font={f, math.ceil(fs * 2)}}
	quest:setTextShadow(3)
	quest:setShadowShader(Shader.default.textoutline and Shader.default.textoutline.shad, 2)

	local info = Textzone.new{auto_width=true, auto_height=true, text='#ANTIQUE_WHITE#(See your Journal for further details or click here)', font={f, math.ceil(fs)}}
	info:setTextShadow(3)
	info:setShadowShader(Shader.default.textoutline and Shader.default.textoutline.shad, 2)
	
	local status = Textzone.new{ui="quest", auto_width=true, auto_height=true, text="#cc9f33#"..(statuses[status] or "????"), has_box=true, font={FontPackage:getFont("bignews")}}
	status:setTextShadow(3)
	status:setShadowShader(Shader.default.textoutline and Shader.default.textoutline.shad, 2)
   
	self:loadUI{
		{hcenter=0, top=0, ui=quest},
		{hcenter=0, bottom=quest.h, ui=info},
		{hcenter=0, top=self.h * 1, ignore_size=true, ui=status},
	}
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

-- Any clicks inside will open the journal
function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	if event ~= "button" or button ~= "left" then return end
	game:unregisterDialog(self)
	game:registerDialog(require("engine.dialogs.ShowQuests").new(game.party:findMember{main=true}, self.quest.id))
end

function _M:drawFrame(x, y, r, g, b, a)
	-- Draw the glow
	if a >= 1 then
		local a = (1 + math.sin(core.game.getTime() / 500)) / 2
		local x = x + self.frame.ox1
		local y = y + self.frame.oy1
		local mw = math.floor(self.frame.w / 2)
		local blhw = math.floor(self.blight.w / 2)
		local blhh = math.floor(self.blight.h / 2)
		local b8hh = math.floor(self.b8.h / 2)
		self.blight.t:toScreenFull(x + mw - blhw, y - blhh + b8hh, self.blight.w, self.blight.h, self.blight.tw, self.blight.th, r, g, b, 0.5 + 0.5 * a)
	end
	
	Dialog.drawFrame(self, x, y, r, g, b, a)
end
