extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_craft_resource_body_entered(body: Node3D):
	var player = body as Player
	if player:
		player.add_pumpkin()
		queue_free()