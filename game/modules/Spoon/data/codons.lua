newCodonType{ type = "normal", name = "hp", description = "raises hp"}

newCodon{
	name = "HP",
	type = {"normal", 1},
	info = function(self, c)
		return "Ups HP."
	end,
}