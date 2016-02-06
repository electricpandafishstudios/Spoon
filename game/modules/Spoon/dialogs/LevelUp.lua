require "engine.class"
local Dialog = require "engine.ui.Dialog"
local Empty = require "engine.ui.Empty"
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
	self.c_1_1 = Button.new{can_focus = self:canUse(3,0,0,0), can_focus_mouse=self:canUse(3,0,0,0), text="UUU", fct=function() if self:canUse(3,0,0,0, true) then self:use("HP") self:used("UUU") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		end
	end}
	if self:haveUsed(self.c_1_1.text) then self.c_1_1 = Button.new{can_focus = false, can_focus_mouse=false, text="", fct=function()end, on_select=function()end} end
	
	self.c_1_2 = Button.new{can_focus = self:canUse(2,1,0,0), can_focus_mouse=self:canUse(2,1,0,0), text="UUC", fct=function() if self:canUse(2,1,0,0) then self:use("HP") self:used("UUC")else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		end
	end}
	if self:haveUsed(self.c_1_2.text) then self.c_1_1 = Button.new{can_focus = false, can_focus_mouse=false, text="", fct=function()end, on_select=function()end} end
	
	self.c_1_3 = Button.new{can_focus = self:canUse(2,0,1,0), can_focus_mouse=self:canUse(2,0,1,0), text="UUA", fct=function() if self:canUse(2,0,1,0) then self:use("HP") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		end
	end}
	self.c_1_4 = Button.new{can_focus = self:canUse(2,0,0,1), can_focus_mouse=self:canUse(2,0,0,1), text="UUG", fct=function() if self:canUse(2,0,0,1) then self:use("HP") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_1_5 = Button.new{can_focus = true, can_focus_mouse=true, text="CUU", fct=function() if self:canUse(2,1,0,0) then self:use("HP") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_1_6 = Button.new{can_focus = true, can_focus_mouse=true, text="CUC", fct=function() if self:canUse(2,1,0,0) then self:use("HP") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_1 = Button.new{can_focus = true, can_focus_mouse=true, text="CUA", fct=function() if self:canUse(1,1,1,0) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_2 = Button.new{can_focus = true, can_focus_mouse=true, text="CUG", fct=function() if self:canUse(1,1,0,1) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_3 = Button.new{can_focus = true, can_focus_mouse=true, text="AUU", fct=function() if self:canUse(2,0,1,0) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_4 = Button.new{can_focus = true, can_focus_mouse=true, text="AUC", fct=function() if self:canUse(1,1,1,0) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_5 = Button.new{can_focus = true, can_focus_mouse=true, text="AUA", fct=function() if self:canUse(1,0,2,0) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.c_2_6 = Button.new{can_focus = true, can_focus_mouse=true, text="AUG", fct=function() if self:canUse(1,0,1,1) then self:use("DAM") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.u_1_1 = Button.new{can_focus = true, can_focus_mouse=true, text="GUU", fct=function() if self:canUse(2,0,0,1) then self:use("FB") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.u_1_2 = Button.new{can_focus = true, can_focus_mouse=true, text="GUC", fct=function() if self:canUse(1,1,0,1) then self:use("FB") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.u_1_3 = Button.new{can_focus = true, can_focus_mouse=true, text="GUA", fct=function() if self:canUse(1,0,1,1) then self:use("FB") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	self.u_1_4 = Button.new{can_focus = true, can_focus_mouse=true, text="GUG", fct=function() if self:canUse(1,0,0,2) then self:use("FB") else self:cantUse() end end, on_select=function()
		local str = desc_types
		if self.no_tooltip then
			self.c_desc:erase()
			self.c_desc:switchItem(str, str, true)
		
		end
	end}
	
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

function _M:cantUse()
	game:unregisterDialog(self)
end

function _M:used(codon)
	self.actor.codons[codon] = 1
end

function _M:haveUsed(codon)
	if self.actor.codons[codon] then return true else return false end
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
