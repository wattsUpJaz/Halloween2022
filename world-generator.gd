extends Node3D

class_name WorldGenerator

enum {AXIS_X, AXIS_Z}
## Size in meters
@export var sector_size := 3.0
## Number of sectors to generate on each axis
@export var sector_axis_count := 10
## Seed to generate the world.
@export var start_seed := "world_generation"
## PackedScene to randomly place
@export var Pumpkin : PackedScene = preload("res://items/pumpkin.tscn")
@export var pumpkin_density := 3
## Player reference
@export var player_path: NodePath

## Generated sectors and their contents
var _sectors := {}
## Current sector the player is in
var _current_sector := Vector3.ZERO
## Random number generator
var _rng := RandomNumberGenerator.new()

@onready var _half_sector_size := sector_size / 2.0
@onready var _sector_size_squared := sector_size * sector_size
@onready var _half_sector_count := int(sector_axis_count / 2.0)
@onready var _player : Player = get_node(player_path) as Player

func _ready() -> void:
	generate()

func _physics_process(_delta: float) -> void:
	# Every frame, we compare the player's position to the current sector. If
	# they move far enough from it, we need to update the world.
	var sector_location := _current_sector * sector_size
	if _player.global_position.distance_squared_to(sector_location) > _sector_size_squared:
		# Our function to update the sectors takes a vector to offset. As the
		# player can be moving left, right, up, or down, we store that
		# information in our sector_offset variable.
		var sector_offset := Vector3.ZERO
		sector_offset = (_player.global_position - sector_location) / sector_size
		sector_offset.x = int(sector_offset.x)
		sector_offset.z = int(sector_offset.z)

		_update_sectors(sector_offset)

## Calls `_generate_sector()` for each sector in a grid around the player.
func generate() -> void:
	for x in range(-_half_sector_count, _half_sector_count):
		for y in range(-_half_sector_count, _half_sector_count):
			_generate_sector(x, y)

# Generates asteroids and places them inside
# of the sector's bounds with a random position, rotation, and scale.
func _generate_sector(x_id: int, y_id: int) -> void:
	_rng.seed = make_seed_for(x_id, y_id)

	# List of entities generated in this sector.
	var sector_data := []
	# Generates random Vector2 in a square and assign an asteroid to it, with a
	# random angle and scale. The asteroids can overlap.
	for _i in range(pumpkin_density):
		var pumpkin : Item = Pumpkin.instantiate()
		add_child(pumpkin)

		# We generate a random position and scale for each asteroid within the rectangle's bounds.
		pumpkin.position = _generate_random_position(x_id, y_id, pumpkin.position.y)
		pumpkin.scale *= _rng.randf_range(0.2, 1.0)
		sector_data.append(pumpkin)

	# We store references to all asteroids to free them later.
	_sectors[Vector2(x_id, y_id)] = sector_data
	
## Creates a text string for the seed with the format "seed_x_y" and uses the hash method to turn it into an integer. This allows us to use it with the `RandomNumberGenerator.seed` property.
func make_seed_for(_x_id: int, _y_id: int, custom_data := "") -> int:
	var new_seed := "%s_%s_%s" % [start_seed, _x_id, _y_id]
	if not custom_data.is_empty():
		new_seed = "%s_%s" % [new_seed, custom_data]
	return new_seed.hash()
	
# Returns a random position within the sector's bounds, given the sector's coordinates.
func _generate_random_position(x_id: int, y_id: int, y_pos : float) -> Vector3:
	# Calculate the sector boundaries based on the current x and y sector
	# coordinates.
	var sector_position = Vector2(x_id * sector_size, y_id * sector_size)
	var sector_top_left = Vector2(
		sector_position.x - _half_sector_size, sector_position.y - _half_sector_size
	)
	var sector_bottom_right = Vector2(
		sector_position.x + _half_sector_size, sector_position.y + _half_sector_size
	)

	return Vector3(
		_rng.randf_range(sector_top_left.x, sector_bottom_right.x),
		y_pos,
		_rng.randf_range(sector_top_left.y, sector_bottom_right.y)
	)

## Updates generated sectors around the player based on `difference`, a cell offset.
func _update_sectors(difference: Vector3) -> void:
	_update_along_axis(AXIS_X, difference.x)
	_update_along_axis(AXIS_Z, difference.z)
	
## Travels along an axis and a direction, erasing sectors in the perpendicular axis that are too far
## away from the player and generating new sectors that come into this range.
func _update_along_axis(axis: int, difference: float) -> void:

	if difference == 0 or (axis != AXIS_X and axis != AXIS_Z):
		return

	# We're going to use the `difference` argument in calculations below to determine the sectors to
	# generate and to delete.
	# Depending on the direction the player is moving, we need to correct for the calculations
	# below.
	# When `difference` is positive, we end up in situations where sectors aren't erased or added on
	# time. This value is there to catch those cases.
	var axis_modifier := int(difference > 0)
	# We extract the `_current_sector`'s row or column depending on the axis we want to walk.
	var sector_axis_coordinate := _current_sector.x if axis == AXIS_X else _current_sector.z
	# We calculate the coordinate of the row or column of the new line of sectors to create.
	var new_sector_line_index := int(
		sector_axis_coordinate + (_half_sector_count - axis_modifier) * difference + difference
	)

	# We find the range of coordinates of the row or column *perpendicular* to the
	# axis we're updating.
	var other_axis_position := _current_sector.z if axis == AXIS_X else _current_sector.x
	var other_axis_min := other_axis_position - _half_sector_count
	var other_axis_max := other_axis_position + _half_sector_count

	# We generate a new entire row or column perpendicular to the axis along which we're moving.
	for other_axis_coordinate in range(other_axis_min, other_axis_max):
		var x := new_sector_line_index if axis == AXIS_X else other_axis_coordinate
		var y := other_axis_coordinate if axis == AXIS_X else new_sector_line_index
		_generate_sector(x, y)

	# We then want to delete the row or column on the opposite end of the grid.
	var obsolete_sector_line_index := int(new_sector_line_index + sector_axis_count * -difference)
	for other_axis_coordinate in range(other_axis_min, other_axis_max):
		var key := Vector2(
			obsolete_sector_line_index if axis == AXIS_X else other_axis_coordinate,
			other_axis_coordinate if axis == AXIS_X else obsolete_sector_line_index
		)

		# We free all asteroids in this sector and remove the corresponding key.
		if _sectors.has(key):
			var sector_data: Array = _sectors[key]
			for d in sector_data:
				if is_instance_valid(d):
					d.queue_free()
			var _found := _sectors.erase(key)

	# And now we're done updating the world, we update the `_current_sector`.
	if axis == AXIS_X:
		_current_sector.x += difference
	else:
		_current_sector.z += difference
