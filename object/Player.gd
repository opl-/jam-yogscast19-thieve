extends RigidBody

onready var mesh = $"Mesh"

func _ready():
	pass

func get_input_dir():
	var dir = Vector3(0, 0, 0)

	if Input.is_action_pressed("game_left"):
		dir += Vector3(-1, 0, 0)
	if Input.is_action_pressed("game_right"):
		dir += Vector3(1, 0, 0)
	if Input.is_action_pressed("game_down"):
		dir += Vector3(0, 0, 1)
	if Input.is_action_pressed("game_up"):
		dir += Vector3(0, 0, -1)

	dir = dir.normalized()
	if dir.length() > 0:
		dir += Vector3(0, 0.1, 0)

	return dir

func _physics_process(delta):
	apply_central_impulse(get_input_dir() * delta * 100)

	if self.linear_velocity.length() > 0.1:
		var lookAt = self.linear_velocity
		lookAt.y = 0
		mesh.look_at(mesh.global_transform.origin + lookAt.normalized(), Vector3(0, 1, 0))
