extends Item

func _affect_player(player: Player):
	player.add_stamina(10)
	player.add_food(5)
	player.add_courage(5)
	$Timer.start()
	await $Timer.timeout
	player.add_stamina(-10)
