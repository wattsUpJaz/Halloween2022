extends Item

func _affect_player(player: Player):
	player.add_food(3)
	player.add_courage(3)
