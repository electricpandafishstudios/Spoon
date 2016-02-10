require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Empty = require "engine.ui.Empty"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local ModalButton = require "mod.ui.ModalButton"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"


module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Available Aminos!", 800, 500)

	self:generateList()
	
	self.c_1_1 = ModalButton.new{mode=self:getMode("UUU", 3,0,0,0), text="UUU", fct=function() self:functionMode(self.c_1_1.mode, "UUU", "HP", 3,0,0,0) end, on_select=function()end}
	self.c_1_2 = ModalButton.new{mode=self:getMode("UUC", 2,1,0,0), text="UUC", fct=function() self:functionMode(self.c_1_2.mode, "UUC", "HP", 2,1,0,0) end, on_select=function()end}
	self.c_1_3 = ModalButton.new{mode=self:getMode("UUA", 2,0,1,0), text="UUA", fct=function() self:functionMode(self.c_1_3.mode, "UUA", "HP", 2,0,1,0) end, on_select=function()end}
	self.c_1_4 = ModalButton.new{mode=self:getMode("UUG", 2,0,0,1), text="UUG", fct=function() self:functionMode(self.c_1_4.mode, "UUG", "HP", 2,0,0,1) end, on_select=function()end}
	self.c_1_5 = ModalButton.new{mode=self:getMode("CUU", 2,1,0,0), text="CUU", fct=function() self:functionMode(self.c_1_5.mode, "CUU", "HP", 2,1,0,0) end, on_select=function()end}
	self.c_1_6 = ModalButton.new{mode=self:getMode("CUC", 1,2,0,0), text="CUC", fct=function() self:functionMode(self.c_1_6.mode, "CUC", "HP", 1,2,0,0) end, on_select=function()end}

	self.c_2_1 = ModalButton.new{mode=self:getMode("CUA", 1,1,1,0), text="CUA", fct=function() self:functionMode(self.c_2_1.mode, "CUA", "DAM", 1,1,1,0) end, on_select=function()end}
	self.c_2_2 = ModalButton.new{mode=self:getMode("CUG", 1,1,0,1), text="CUG", fct=function() self:functionMode(self.c_2_2.mode, "CUG", "DAM", 1,1,0,1) end, on_select=function()end}
	self.c_2_3 = ModalButton.new{mode=self:getMode("AUU", 2,0,1,0), text="AUU", fct=function() self:functionMode(self.c_2_3.mode, "AUU", "DAM", 2,0,1,0) end, on_select=function()end}
	self.c_2_4 = ModalButton.new{mode=self:getMode("AUC", 1,1,1,0), text="AUC", fct=function() self:functionMode(self.c_2_4.mode, "AUC", "DAM", 1,1,1,0) end, on_select=function()end}
	self.c_2_5 = ModalButton.new{mode=self:getMode("AUA", 1,0,2,0), text="AUA", fct=function() self:functionMode(self.c_2_5.mode, "AUA", "DAM", 1,0,2,0) end, on_select=function()end}
	self.c_2_6 = ModalButton.new{mode=self:getMode("AUG", 1,0,1,1), text="AUG", fct=function() self:functionMode(self.c_2_6.mode, "AUG", "DAM", 1,0,1,1) end, on_select=function()end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}

	self.u_1_1 = ModalButton.new{mode=self:getMode("GUU", 2,0,0,1), text="GUU", fct=function() self:functionMode(self.u_1_1.mode, "GUU", "FB", 2,0,0,1) end, on_select=function()end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}
	self.u_1_2 = ModalButton.new{mode=self:getMode("GUC", 1,1,0,1), text="GUC", fct=function() self:functionMode(self.u_1_2.mode, "GUC", "FB", 1,1,0,1) end, on_select=function()end}
	self.u_1_3 = ModalButton.new{mode=self:getMode("GUA", 1,0,1,1), text="GUA", fct=function() self:functionMode(self.u_1_3.mode, "GUA", "FB", 1,0,1,1) end, on_select=function()end}
	self.u_1_4 = ModalButton.new{mode=self:getMode("GUG", 1,0,0,2), text="GUG", fct=function() self:functionMode(self.u_1_4.mode, "GUG", "FB", 1,0,0,2) end, on_select=function()end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}
		-- local str = desc_types
		-- if self.no_tooltip then
			-- self.c_desc:erase()
			-- self.c_desc:switchItem(str, str, true)
		
		-- end
	-- end}
	
	local b_height = 25
	local b_width = 50
	
	self.a_1 = Textzone.new{width=90, height=(6*b_height)-18, text=[[HP]], has_box=true}
	self.a_2 = Textzone.new{width=90, height=(6*b_height)-18, text=[[DAM]], has_box=true}
	self.a_3 = Textzone.new{width=90, height=(4*b_height)-12, text=[[FB]], has_box=true}
	
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

function _M:getMode(codon, U, C, A, G)
	if self.actor.codons[codon] then
		return "USED"
	elseif self:canUse(U,C,A,G) then
		return "AVAIL"
	else
		return "UNAVAIL"
	end
end

function _M:functionMode(mode, codon, item,U,C,A,G)
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
