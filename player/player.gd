extends CharacterBody3D

class_name Player

const SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var stats : Dictionary = {
	"health": $PlayerUI/VBoxContainer/HealthStat,
	"food": $PlayerUI/VBoxContainer/FoodStat,
	"stamina": $PlayerUI/VBoxContainer/StaminaStat,
	"courage": $PlayerUI/VBoxContainer/CourageStat}

func _ready():
	randomize()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var speed = SPEED

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

func add_food(value: int):
	stats["food"].add(value)

func add_courage(value: int):
	stats["courage"].add(value)

func add_stamina(value: int):
	stats["stamina"].add(value)
	
func add_health(value: int):
	stats["health"].add(value)
