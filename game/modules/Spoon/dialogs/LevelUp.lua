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
	self.b_1 = Button.new{can_focus = false, can_focus_mouse=true, text="UUU", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_2 = Button.new{can_focus = false, can_focus_mouse=true, text="UUC", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_3 = Button.new{can_focus = false, can_focus_mouse=true, text="UUA", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_4 = Button.new{can_focus = false, can_focus_mouse=true, text="UUG", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_5 = Button.new{can_focus = false, can_focus_mouse=true, text="CUU", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.b_6 = Button.new{can_focus = false, can_focus_mouse=true, text="CUC", fct=function() self:use("HP") end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		-- elseif self.b_stat.last_display_x then
			-- game:tooltipDisplayAtMap(self.b_stat.last_display_x + self.b_stat.w, self.b_stat.last_display_y, str)
		end
	end}
	self.a_1 = Textzone.new{width=90, height=130, text=[[HP]], has_box=true}

	self:loadUI{
		--{left=0, top=0, ui=self.c_desc},
		--{left=5, top=self.c_desc.h, padding_h=10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
		{left=0, top=0, ui=self.b_1},
		{left=0, top=self.b_1.h-6, ui=self.b_2},
		{left=0, top=(self.b_1.h-6) * 2, ui=self.b_3},
		{left=0, top=(self.b_1.h-6) * 3, ui=self.b_4},
		{left=0, top=(self.b_1.h-6) * 4, ui=self.b_5},
		{left=0, top=(self.b_1.h-6) * 5, ui=self.b_6},
		{left=self.b_1.w+2, top=10, ui=self.a_1}
	}
	self.key:addBind("EXIT", function() game:unregisterDialog(self) end)
	self:setFocus(self.b_1)
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
