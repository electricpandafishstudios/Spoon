require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Level Increased!", 500, 300)

	self:generateList()

	self.c_desc = Textzone.new{width=self.iw, auto_height=true, text=[[You have gained one level, and now you must
choose a stat to decrement; but choose wisely. You won't be able to get it back!]]}
	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
		{left=5, top=self.c_desc.h, padding_h=10, ui=Separator.new{dir="vertical", size=self.iw - 10}},
		{left=0, bottom=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)
end

function _M:use(item)
	if not item then return end
	local act = item.action

	if act == "A" then
		self.actor:incStat(game.player.STAT_A, -1)
	elseif act == "U" then
		self.actor:incStat(game.player.STAT_T, -1)
	elseif act == "C" then
		self.actor:incStat(game.player.STAT_C, -1)
	elseif act == "G" then
		self.actor:incStat(game.player.STAT_G, -1)
	end
	game:unregisterDialog(self)
	self.actor:recalculateStats()
end

function _M:generateList()
	local list = {}

	list[#list+1] = {name="A: Heats up the action", action ="A"}
	list[#list+1] = {name="U: Adds to Sturdiness", action ="U"}
	list[#list+1] = {name="G: ???", action ="G"}
	list[#list+1] = {name="C: Bulk Up", action ="C"}
	self.list = list
end
