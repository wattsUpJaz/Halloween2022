extends Area3D

class_name Item
var item_name : String

func _affect_player(_player: Player):
	const msg: String = "_affect_player() is not implemented in Item"
	assert(false, msg)

func _on_craft_resource_body_entered(body: Node3D):
	var player = body as Player
	if player:
		$CollisionShape3d.set_deferred("disabled",true)
		$Sprite3d.set_deferred("visible",false)
		await _affect_player(player)
		queue_free()
