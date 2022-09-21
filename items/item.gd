extends Area3D

class_name Item

func _affect_player(player: Player):
	push_error("_affect_player() is not implemented in Item")

func _on_craft_resource_body_entered(body: Node3D):
	var player = body as Player
	if player:
		_affect_player(player)
		queue_free()
