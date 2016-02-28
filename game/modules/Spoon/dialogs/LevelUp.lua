require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Empty = require "engine.ui.Empty"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local ModalButton = require "mod.ui.ModalButton"
--local Aminos = require "mod.data.aminos"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Available Aminos!", 800, 500)

	self:generateList()
	
	-- Common Slots
	self.c_1_1 = self:makeButton("UUU", 3, 0, 0, 0, "HP")
	self.c_1_2 = self:makeButton("UUC", 2, 1, 0, 0, "HP")
	self.c_1_3 = self:makeButton("UUA", 2, 0, 1, 0, "HP")
	self.c_1_4 = self:makeButton("UUG", 2, 0, 0, 1, "HP")
	self.c_1_5 = self:makeButton("CUU", 2, 0, 1, 0, "HP")
	self.c_1_6 = self:makeButton("CUC", 1, 2, 0, 0, "HP")
	
	self.c_2_1 = self:makeButton("CUA", 1, 1, 1, 0, "DAM")
	self.c_2_2 = self:makeButton("CUG", 1, 1, 0, 1, "DAM")
	self.c_2_3 = self:makeButton("AUU", 2, 0, 1, 0, "DAM")
	self.c_2_4 = self:makeButton("AUC", 1, 1, 1, 0, "DAM")
	self.c_2_5 = self:makeButton("AUA", 1, 0, 2, 0, "DAM")
	self.c_2_6 = self:makeButton("AUG", 1, 0, 1, 1, "DAM")
	

	--Uncommon Slots
	self.u_1_1 = self:makeButton("GUU", 2, 0, 0, 1, "FB")
	self.u_1_2 = self:makeButton("GUC", 1, 1, 0, 1, "FB")
	self.u_1_3 = self:makeButton("GUA", 1, 0, 1, 1, "FB")
	self.u_1_4 = self:makeButton("GUG", 1, 0, 0, 2, "FB")
	
	
	local b_height = 25
	local b_width = 50
	
	self.a_1 = Textzone.new{width=90, height=(6*b_height)-18, text=[[Health: Increases your max Life by 1.]], has_box=true}
	
	--self.a_1 = Textzone.new{width=90, height=(6*b_height)-18, text=, has_box=true}

	self.a_2 = Textzone.new{width=90, height=(6*b_height)-18, text=[[Damage: Increases your damage by 1.]], has_box=true}
	self.a_3 = Textzone.new{width=90, height=(4*b_height)-12, text=[[Fireball: Ranged attack of radius 2. Deals 1 damage per Codon purchased.]], has_box=true}
	
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

function _M:makeButton(btext, U, C, A, G, act)
	local bMode = self:getMode(btext, U, C, A, G)
	return ModalButton.new{mode=bMode, text=btext, fct=function() self:functionMode(bMode, btext, U, C, A, G, act) end, on_select=function()end}
end

function _M:getMode(codon, U, C, A, G)
	if self.actor.codons[codon] then
		return "USED"
	elseif self:canUse(U,C,A,G) then
		return "AVAIL"
	else
		return "UNAVAIL"
	end
end

function _M:functionMode(mode, codon, U, C, A, G, item)
	if not mode then return end
	local fct = mode
	if fct == "AVAIL" then
		self:use(item)
		self.actor.codons[codon] = 1
		self:decrement(U,C,A,G)
	elseif fct == "USED" then
		game:unregisterDialog(self)
	elseif fct == "UNAVAIL" then
		game:unregisterDialog(self)
	end
end


function _M:canUse(U,C,A,G, dec)
	
	if self.actor:getU() < U then return false end
	if self.actor:getC() < C then return false end
	if self.actor:getA() < A then return false end
	if self.actor:getG() < G then return false end
	if dec then
		self.actor:incStat(game.player.STAT_U, -U)
		self.actor:incStat(game.player.STAT_C, -C)
		self.actor:incStat(game.player.STAT_A, -A)
		self.actor:incStat(game.player.STAT_G, -G)
	end
	return true
end

function _M:decrement(U,C,A,G)
	self.actor:incStat(game.player.STAT_U, -U)
	self.actor:incStat(game.player.STAT_C, -C)
	self.actor:incStat(game.player.STAT_A, -A)
	self.actor:incStat(game.player.STAT_G, -G)
end

function _M:use(item)
	if not item then return end
	local act = item

	if act == "HP" then
		self.actor:gainAmino("A_HP")
	elseif act == "DAM" then
		self.actor:gainAmino("A_DAM")
	elseif act == "FB" then
		self.actor:gainAmino("A_FIRE_BALL")
	end
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
