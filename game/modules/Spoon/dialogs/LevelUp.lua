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
	Dialog.init(self, "New Codon Available!", 500, 300)

	self:generateList()

	self.c_desc = Textzone.new{width=self.iw, auto_height=true, text=[[Spend your bases here]]}
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
	local list = {}

	list[#list+1] = {name="HP: Adds one point of health. (AGC)", action ="HP"}
	list[#list+1] = {name="Attack: Adds one point of damage. (UGC)", action ="DAM"}
	list[#list+1] = {name="Fire Ball: Grants Fire Ball ability. (AGU)", action ="FB"}
	self.list = list
end
