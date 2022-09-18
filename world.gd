extends Node3D

var craft_rsrc_scene: PackedScene = preload("res://craft-resource.tscn")
var rsrc_count: int = 5

func _ready():
	randomize()
	for _i in range(rsrc_count):
		var instance: Area3D = craft_rsrc_scene.instantiate()
		instance.position = Vector3(randi_range(-10,10),instance.position.y, randi_range(-10,10))
		add_child(instance)
