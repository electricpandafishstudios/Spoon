newCodonType{ type = "normal", name = "hp", description = "raises hp"}

newCodon{
	name = "HP",
	type = {"normal"},
	sequences = {"AGC"},
	on_gain = function(self, c)
		self.max_life = self.max_life + 1
		self.life = self.max_life
	end,
	info = function(self, c)
		return "Ups HP."
	end,
}

newCodon{
	name = "Dam",
	type = {"normal"},
	sequences = {"UGC"},
	on_gain = function(self, c)
		self.combat.dam = self.combat.dam + 1
	end,
	info = function(self, c)
		return "Ups damage."
	end,
}

newCodon{
	name = "Fire ball",
	type = {"normal"},
	sequences = {"AGU"},
	on_gain = function(self, c)
		self:learnTalent("T_FIRE_BALL", true, 1)
	end,
	info = function(self, c)
		return "FIRE."
	end,
}
