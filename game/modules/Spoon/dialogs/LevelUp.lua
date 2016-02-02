require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Available Aminos!", 800, 500)

	self:generateList()

	--self.c_desc = Textzone.new{width=self.iw, auto_height=true, text=[[Spend your bases here]]}
	--self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}
	self.b_types = Button.new{can_focus = false, can_focus_mouse=true, text="AAA", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}

	self:loadUI{
		--{left=0, top=0, ui=self.c_desc},
		--{left=5, top=self.c_desc.h, padding_h=10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
		{left=0, top=0, ui=self.b_types}
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)
end

function _M:use(item)
	if not item then return end
	local act = item

	if act == "HP" then
		self.actor:gainCodon("C_HP")
		self.actor:incStat(game.player.STAT_A, -1)
		self.actor:incStat(game.player.STAT_G, -1)
		self.actor:incStat(game.player.STAT_C, -1)
	elseif act == "DAM" then
		self.actor:gainCodon("C_DAM")
		self.actor:incStat(game.player.STAT_U, -1)
		self.actor:incStat(game.player.STAT_G, -1)
		self.actor:incStat(game.player.STAT_C, -1)
	elseif act == "FB" then
		self.actor:gainCodon("C_FIRE_BALL")
		self.actor:incStat(game.player.STAT_A, -1)
		self.actor:incStat(game.player.STAT_G, -1)
		self.actor:incStat(game.player.STAT_U, -1)
	end
	game:unregisterDialog(self)
end

function _M:generateList()
	profile.chat:selectChannel("tome")

	-- Makes up the list
	local list = {}
	for i=0,16 do
			list[#list+1] = { player="name", character="char"}
	end
	self.list=list
end
