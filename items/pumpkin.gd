extends Item

func _affect_player(player: Player):
	player.add_food(10)
