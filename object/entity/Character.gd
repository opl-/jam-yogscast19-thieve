extends RigidBody
class_name Character

onready var mesh = $"Rig"
onready var animationPlayer: AnimationPlayer = $"Rig/AnimationPlayer"
onready var itemHold: Position3D = $"Rig/Hold"

#warning-ignore:unused_argument
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

func dropHeldItem(strength: float = 0) -> Item:
	var dropTo := get_node_or_null("../..")

	if itemHold.get_child_count() == 0 or not dropTo:
		return null

	var heldItem = itemHold.get_child(0) as Item

	Util.reparent(heldItem, $"../..")
	heldItem.collision_layer |= 4
	heldItem.mode = RigidBody.MODE_RIGID

	var dir = linear_velocity.normalized()

	heldItem.global_transform.origin = itemHold.global_transform.origin + dir * 0.3

	if strength > 0:
		dir.y += 0.2
		heldItem.apply_central_impulse(dir.normalized() * strength * 20)

	return heldItem

func takeItem(item: Item) -> bool:
	if not item or Util.isHeld(item):
		return false

	item.translation = Vector3(0, 0, 0)
	item.collision_layer &= ~4
	item.mode = RigidBody.MODE_STATIC
	Util.reparent(item, itemHold)

	item.lastHolder = self

	return true
