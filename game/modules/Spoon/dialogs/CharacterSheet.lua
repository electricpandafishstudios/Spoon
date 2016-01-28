require "engine.class"

local Dialog = require "engine.ui.Dialog"
local Talents = require "engine.interface.ActorTalents"
local SurfaceZone = require "engine.ui.SurfaceZone"
local Stats = require "engine.interface.ActorStats"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
   self.actor = actor

   self.font = core.display.newFont("/data/font/VeraMono.ttf", 12)
   Dialog.init(self, "Character Sheet", math.max(game.w * 0.7, 950), 500, nil, nil, font)

   self.c_desc = SurfaceZone.new{width=self.iw, height=self.ih,alpha=0}

   self:loadUI{
       {left=0, top=0, ui=self.c_desc},
   }

   self:setupUI()

   self:drawDialog()

   self.key:addBind("EXIT", function() cs_player_dup = game.player:clone() game:unregisterDialog(self) end)
end

function _M:drawDialog()
   local player = self.actor
   local s = self.c_desc.s

   s:erase(0,0,0,0)

   local h = 0
   local w = 0

   h = 0
   w = 0
   -- start on second column

   s:drawStringBlended(self.font, "A: "..(player:getA()), w, h, 0, 255, 255, true) h = h + self.font_h
   s:drawStringBlended(self.font, "U: "..(player:getU()), w, h, 255, 0, 255, true) h = h + self.font_h
   s:drawStringBlended(self.font, "G: "..(player:getG()), w, h, 255, 255, 0, true) h = h + self.font_h
   s:drawStringBlended(self.font, "C: "..(player:getC()), w, h, 0, 255, 255, true) h = h + self.font_h

   s:drawStringBlended(self.font, "Codons: ", w, h, 0, 255, 255, true) h = h + self.font_h
   for i, v in ipairs(player.codons) do
     s:drawStringBlended(self.font, i..": "..v, w, h, 0, 255, 255, true) h = h + self.font_h
   end

   self.c_desc:generate()
   self.changed = false
end
