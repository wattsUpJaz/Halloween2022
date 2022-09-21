extends Node3D

var pumpkin_scene: PackedScene = preload("res://items/pumpkin.tscn")
var acorn_scene: PackedScene = preload("res://items/acorn.tscn")
var dandelion_scene: PackedScene = preload("res://items/dandelion.tscn")
var rsrc_count: int = 5

func _ready():
	randomize()
	_randomly_place_item(pumpkin_scene)
	_randomly_place_item(dandelion_scene)
	_randomly_place_item(acorn_scene)
	
func _randomly_place_item(scene: PackedScene):
	for _i in range(rsrc_count):
		var instance: Area3D = scene.instantiate()
		instance.position = Vector3(randi_range(-12,12),instance.position.y, randi_range(-15,15))
		add_child(instance)
