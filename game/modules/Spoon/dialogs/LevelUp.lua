require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Empty = require "engine.ui.Empty"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local ModalButton = require "mod.ui.ModalButton"
local ActorAminos = require "mod.class.interface.ActorAminos"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Available Aminos!", 800, 500)

	self:generateList()
	
	-- Common Slots
	self.c_1_1 = self:makeButton("UUU", 3, 0, 0, 0, "A_HP")
	self.c_1_2 = self:makeButton("UUC", 2, 1, 0, 0, "A_HP")
	self.c_1_3 = self:makeButton("UUA", 2, 0, 1, 0, "A_HP")
	self.c_1_4 = self:makeButton("UUG", 2, 0, 0, 1, "A_HP")
	self.c_1_5 = self:makeButton("CUU", 2, 0, 1, 0, "A_HP")
	self.c_1_6 = self:makeButton("CUC", 1, 2, 0, 0, "A_HP")
	
	self.c_2_1 = self:makeButton("CUA", 1, 1, 1, 0, "A_DAM")
	self.c_2_2 = self:makeButton("CUG", 1, 1, 0, 1, "A_DAM")
	self.c_2_3 = self:makeButton("AUU", 2, 0, 1, 0, "A_DAM")
	self.c_2_4 = self:makeButton("AUC", 1, 1, 1, 0, "A_DAM")
	self.c_2_5 = self:makeButton("AUA", 1, 0, 2, 0, "A_DAM")
	self.c_2_6 = self:makeButton("AUG", 1, 0, 1, 1, "A_DAM")
	

	--Uncommon Slots
	self.u_1_1 = self:makeButton("GUU", 2, 0, 0, 1, "A_FIRE")
	self.u_1_2 = self:makeButton("GUC", 1, 1, 0, 1, "A_FIRE")
	self.u_1_3 = self:makeButton("GUA", 1, 0, 1, 1, "A_FIRE")
	self.u_1_4 = self:makeButton("GUG", 1, 0, 0, 2, "A_FIRE")
	
	
	local b_height = 25
	local b_width = 50
	
	local aminos = game.player.aminos_def
	
	self.a_1 = self:makeText(90, (6*b_height)-18, "A_HP")
	self.a_2 = self:makeText(90, (6*b_height)-18, "A_DAM")
	self.a_3 = self:makeText(90, (4*b_height)-12, "A_FIRE")
	
	
	local align_c_1 = Empty.new{width=b_width,height=-12}
	local align_c_2 = Empty.new{width=b_width,height=90-12}
	local align_u_1 = Empty.new{width=b_width,height=170-12}

	self:loadUI{
		{left=0, top=0, ui=align_c_1},
		{left=0, top=align_c_2.h, ui=align_c_2},
		{left=0, top=align_c_2, ui=align_u_1},
		

		{left=0, top=align_c_1.h, ui=self.c_1_1},
		{left=0, top=align_c_1.h + b_height, ui=self.c_1_2},
		{left=0, top=align_c_1.h +(b_height*2), ui=self.c_1_3},
		{left=0, top=align_c_1.h +(b_height*3), ui=self.c_1_4},
		{left=0, top=align_c_1.h +(b_height*4), ui=self.c_1_5},
		{left=0, top=align_c_1.h +(b_height*5), ui=self.c_1_6},
		
		{left=0, top=150, ui=self.c_2_1},
		{left=0, top=175, ui=self.c_2_2},
		{left=0, top=200, ui=self.c_2_3},
		{left=0, top=225, ui=self.c_2_4},
		{left=0, top=250, ui=self.c_2_5},
		{left=0, top=275, ui=self.c_2_6},
		
		{left=0, top=310, ui=self.u_1_1},
		{left=0, top=335, ui=self.u_1_2},
		{left=0, top=360, ui=self.u_1_3},
		{left=0, top=385, ui=self.u_1_4},

		{left=align_c_1, top=0, ui=self.a_1},
		{left=align_c_2, top=align_c_2, ui=self.a_2},
		{left=align_u_1, top=align_u_1, ui=self.a_3}
	}
	self.key:addBind("EXIT", function() game:unregisterDialog(self) end)
	self:setFocus(self.c_1_1)
	self:setupUI(false, true)
end

function _M:makeButton(bText, U, C, A, G, act)
	local bMode = self:getMode(bText, U, C, A, G)
	if bMode == "USED" or bMode == "UNAVAIL" then
		return ModalButton.new{mode=bMode, text=bText, fct=function() game:unregisterDialog(self) end, on_select=function()end}
	else
		return ModalButton.new{mode=bMode, text=bText, fct=function() self:use(act) self.actor.codons[bText] = 1 self:decrement(U, C, A, G) end, on_select=function()end}
	end
end

function _M:getMode(codon, U, C, A, G)
	if self.actor.codons[codon] then
		return "USED"
	elseif self:canUse(U, C, A, G) then
		return "AVAIL"
	else
		return "UNAVAIL"
	end
end

function _M:canUse(U, C, A, G)
	if self.actor:getU() < U or self.actor:getC() < C or self.actor:getA() < A or self.actor:getG() < G then return false end
	return true
end

function _M:decrement(U, C, A, G)
	self.actor:incStat(game.player.STAT_U, -U)
	self.actor:incStat(game.player.STAT_C, -C)
	self.actor:incStat(game.player.STAT_A, -A)
	self.actor:incStat(game.player.STAT_G, -G)
end

function _M:makeText(w, h, id)
	local amino = ActorAminos:getAminoFromId(id)
	
	if self.actor:hasAmino(id) then
		return Textzone.new{width=w, height=h, text=([[%s: %s]]):format(ActorAminos:getAminoDisplayName(amino), ActorAminos:getAminoFullDescription(amino)), has_box=true}
	else
		return Textzone.new{width=w, height=h, text=[[??? Purchase a codon to unlock this Amino ???]], has_box=true}
	end
end

function _M:use(item)
	if not item then return end
	local act = item
	self.actor:gainAmino(act)
	self.actor:levelup()
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
