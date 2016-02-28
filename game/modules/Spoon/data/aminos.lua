newAminoType{ type = "common", name = "common", description = "do things"}
newAminoType{ type = "uncommon", name = "uncommon", description = "do things"}

newAmino{
	name = "Health",
	short_name = "HP",
	type = {"common"},
	on_gain = function(self, c)
		self.max_life = self.max_life + 1
		self.life = self.life + 1
	end,
	info = function(self, c)
		return "Increases your max Life by 1."
	end,
}

newAmino{
	name = "Damage",
	short_name = "DAM",
	type = {"common"},
	on_gain = function(self, c)
		self.combat.dam = self.combat.dam + 1
	end,
	info = function(self, c)
		return "Increases your damage by 1."
	end,
}

newAmino{
	name = "Fire Ball",
	short_name= "fire",
	type = {"uncommon"},
	on_gain = function(self, c)
		self:learnTalent("T_FIRE_BALL", true, 1)
	end,
	info = function(self, c)
		return "Ranged attack of radius 2. Deals 1 damage per Codon purchased."
	end,
}
