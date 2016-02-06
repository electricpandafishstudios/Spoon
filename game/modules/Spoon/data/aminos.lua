newAminoType{ type = "common", name = "common", description = "do things"}

newAmino{
	name = "HP",
	type = {"common"},
	on_gain = function(self, c)
		self.max_life = self.max_life + 1
		self.life = self.life + 1
	end,
	info = function(self, c)
		return "Ups HP."
	end,
}

newAmino{
	name = "Dam",
	type = {"common"},
	on_gain = function(self, c)
		self.combat.dam = self.combat.dam + 1
	end,
	info = function(self, c)
		return "Ups damage."
	end,
}

newAmino{
	name = "Fire ball",
	type = {"common"},
	on_gain = function(self, c)
		self:learnTalent("T_FIRE_BALL", true, 1)
	end,
	info = function(self, c)
		return "FIRE."
	end,
}
