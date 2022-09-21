extends Area3D

class_name Item

func _affect_player(player: Player):
	var msg: String = "_affect_player() is not implemented in Item"
	push_error(msg)

func _on_craft_resource_body_entered(body: Node3D):
	var player = body as Player
	if player:
		$CollisionShape3d.disabled = true
		$Sprite3d.visible = false
		await _affect_player(player)
		queue_free()
