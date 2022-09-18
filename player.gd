extends CharacterBody3D

class_name Player

const SPEED = 5.0
var speed_multiplier: float = 1.0
var rand_speeds: Array = [0.5, 2]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# inventory
var pumpkins = 0

# stats
var health = 49

func _ready():
	randomize()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var speed = SPEED * speed_multiplier

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func add_pumpkin():
	health += 10
	if health > 50:
		speed_multiplier = 1
		$Sprite3d.modulate = Color(255,255,255,255)
	#$Sprite3d/Label3d.text = str(pumpkins)

func _on_health_timer_timeout():
	health -= 1
	$PlayerUI/HBoxContainer/HealthCount.text = str(health)

func _on_movement_variance_timer_timeout():
	if health < 50:
		var change = randi_range(0,1)
		change = 1
		if change:
			speed_multiplier = rand_speeds[randi_range(0,1)]
			if speed_multiplier < 1:
				$Sprite3d.modulate = Color(0,0,255,255)
			elif speed_multiplier > 1:
				$Sprite3d.modulate = Color(255,0,0,255)
