extends Character
class_name Player

signal scoreChanged

onready var itemDetector: Area = $"Rig/ItemDetector"
onready var throwStrengthIndicator: Position3D = $"Rig/ThrowIndicator"

var throwStrength: float = -1
var highlightedItem: Item

var score: int = 0

func scoreSet(val: int = -1):
	if val == -1:
		val = score + 1

	score = val

	emit_signal("scoreChanged", val)

func _ready():
	#warning-ignore:return_value_discarded
	itemDetector.connect("body_entered", self, "handleItemDetected")
	#warning-ignore:return_value_discarded
	itemDetector.connect("body_exited", self, "handleItemExit")

func get_input_dir():
	var dir = Vector3(Input.get_action_strength("game_right") - Input.get_action_strength("game_left"), 0, Input.get_action_strength("game_down") - Input.get_action_strength("game_up"))

	if dir.length() > 1:
		dir = dir.normalized()

	return dir

func _physics_process(delta):
	apply_central_impulse(get_input_dir() * delta * 100)

	._physics_process(delta)

	if itemHold.get_child_count() > 0:
		if throwStrength > -1 and Input.is_action_pressed("game_hold"):
			throwStrength = min(1, throwStrength + delta)
		elif Input.is_action_just_pressed("game_hold"):
			throwStrength = -0.2
		elif throwStrength > -1:
			#warning-ignore:return_value_discarded
			dropHeldItem(max(0, throwStrength))

			throwStrength = -1

			call_deferred("tryHighlight")

		throwStrengthIndicator.scale = Vector3(1, 1, throwStrength)
		throwStrengthIndicator.visible = throwStrength > 0
	else:
		if Input.is_action_just_pressed("game_hold") and highlightedItem and not Util.isHeld(highlightedItem):
			takeItem(highlightedItem)
			unhighlightItem(highlightedItem)

func handleItemDetected(arg: RigidBody):
	if Util.isValidItem(arg) and itemHold.get_child_count() == 0 and not Util.isHeld(highlightedItem):
		highlightItem(arg)
	elif arg is NPC and itemHold.get_child_count() > 0:
		var npc := arg as NPC

		if npc.wants == (itemHold.get_child(0) as Item).itemName:
			# TODO: show hint
			pass

func handleItemExit(arg: RigidBody):
	if Util.isValidItem(arg):
		unhighlightItem(arg)

		call_deferred("tryHighlight")

func tryHighlight():
	var overlaps := itemDetector.get_overlapping_bodies()
	if overlaps.size() > 0 and Util.isValidItem(overlaps[0]):
		handleItemDetected(overlaps[0])

func highlightItem(item: Item):
	if not Util.isValidItem(item) or item.get_parent().name == "Hold":
		return

	var mesh := item.get_node("Mesh") as MeshInstance
	if not mesh:
		return

	if highlightedItem:
		unhighlightItem(highlightedItem)

	mesh.set_material_override(preload("res://object/palette-highlight.material"))

	highlightedItem = item

func unhighlightItem(item: Item):
	if not Util.isValidItem(item):
		return

	var mesh := item.get_node("Mesh") as MeshInstance
	if not mesh:
		return

	mesh.set_material_override(null)

	highlightedItem = null
