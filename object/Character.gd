extends RigidBody
class_name Character

onready var mesh = $"Rig"
onready var animationPlayer: AnimationPlayer = $"Rig/AnimationPlayer"

func _physics_process(delta):
	var speed = linear_velocity.length()

	if speed > 0.5:
		animationPlayer.play("walk", 0.2)
		animationPlayer.playback_speed = min(1, speed)
	else:
		animationPlayer.play("idle", 0.1)
		animationPlayer.playback_speed = 1

	if speed > 0.4:
		var lookAt = linear_velocity
		lookAt.y = 0

		if lookAt.length() > 0:
			mesh.look_at(mesh.global_transform.origin + lookAt.normalized(), Vector3(0, 1, 0))
