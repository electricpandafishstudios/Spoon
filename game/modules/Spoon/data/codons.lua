newCodonType{ type = "normal", name = "hp", description = "raises hp"}

newCodon{
	name = "HP",
	type = {"normal", 1},
	on_learn = function(self, c)
		self.max_life = self.max_life + 1
		self.life = self.max_life
	end,
	info = function(self, c)
		return "Ups HP."
	end,
}