extends Character

onready var itemDetector: Area = $"Rig/ItemDetector"
onready var itemHold: Position3D = $"Rig/Hold"
onready var throwStrengthIndicator: Position3D = $"Rig/ThrowIndicator"

var throwStrength: float = 0
var highlightedItem: Item

func _ready():
	itemDetector.connect("body_entered", self, "handleItemDetected")
	itemDetector.connect("body_exited", self, "handleItemExit")

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

	._physics_process(delta)

	if itemHold.get_child_count() > 0:
		if throwStrength > 0 and Input.is_action_pressed("game_hold"):
			throwStrength = min(1, throwStrength + delta)
		elif Input.is_action_just_pressed("game_hold"):
			throwStrength = 0.1
		elif throwStrength > 0:
			var heldItem = itemHold.get_child(0) as Spatial

			var dir = linear_velocity.normalized()

			Util.reparent(heldItem, $"../..")
			heldItem.global_transform.origin = itemHold.global_transform.origin + dir * 0.3
			heldItem.collision_mask |= 1

			dir.y += 0.2
			heldItem.apply_central_impulse(dir.normalized() * throwStrength * 20)

			throwStrength = 0

			call_deferred("tryHighlight")

		throwStrengthIndicator.scale = Vector3(1, 1, throwStrength)
		throwStrengthIndicator.visible = throwStrength > 0
	else:
		if Input.is_action_just_pressed("game_hold") and highlightedItem:
			highlightedItem.global_transform.origin = Vector3(0, 0, 0)
			highlightedItem.collision_mask &= ~1
			Util.reparent(highlightedItem, itemHold)
			unhighlightItem(highlightedItem)

func isValidItem(node: Node):
	return node and node is Item and node.is_in_group("item")

func handleItemDetected(arg: RigidBody):
	if not isValidItem(arg) or itemHold.get_child_count() > 0:
		return

	highlightItem(arg)

func handleItemExit(arg: RigidBody):
	print(arg, " ", isValidItem(arg))
	if not isValidItem(arg):
		return

	unhighlightItem(arg)

	call_deferred("tryHighlight")

func tryHighlight():
	var overlaps := itemDetector.get_overlapping_bodies()
	if overlaps.size() > 0 and isValidItem(overlaps[0]):
		handleItemDetected(overlaps[0])

func highlightItem(item: Item):
	print("highlight ", item)
	if not isValidItem(item):
		return

	var mesh := item.get_node("Mesh") as MeshInstance
	if not mesh:
		return

	if highlightedItem:
		unhighlightItem(highlightedItem)

	mesh.set_material_override(preload("res://object/palette-highlight.material"))

	highlightedItem = item

func unhighlightItem(item: Item):
	print("unhighlight ", item)
	if not isValidItem(item):
		return

	var mesh := item.get_node("Mesh") as MeshInstance
	if not mesh:
		return

	mesh.set_material_override(null)

	highlightedItem = null
