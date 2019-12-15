extends Character
class_name Player

signal scoreChanged
signal updateHint

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

func _input(event):
	if Input.is_action_just_pressed("game_use") and itemHold.get_child_count() > 0:
		itemHold.get_child(0).call_deferred("useItem", self)

func handleItemDetected(arg: RigidBody):
	if Util.isValidItem(arg) and itemHold.get_child_count() == 0 and not Util.isHeld(highlightedItem):
		highlightItem(arg)
	elif arg is NPC and itemHold.get_child_count() > 0:
		var npc := arg as NPC

		if npc.wants == (itemHold.get_child(0) as Item).itemName:
			emit_signal("updateHint", "Gift", true)

func handleItemExit(arg: RigidBody):
	if Util.isValidItem(arg):
		unhighlightItem(arg)

		call_deferred("tryHighlight")
	elif arg is NPC and itemHold.get_child_count() > 0:
		var npc := arg as NPC

		if npc.wants == (itemHold.get_child(0) as Item).itemName:
			emit_signal("updateHint", "Gift", false)

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

	emit_signal("updateHint", "Hold", true)
	mesh.set_material_override(preload("res://object/palette-highlight.material"))

	highlightedItem = item

func unhighlightItem(item: Item):
	if not Util.isValidItem(item):
		return

	var mesh := item.get_node("Mesh") as MeshInstance
	if not mesh:
		return

	emit_signal("updateHint", "Hold", false)
	mesh.set_material_override(null)

	highlightedItem = null

func dropHeldItem(strength: float = 0) -> Item:
	emit_signal("updateHint", "Throw", false)
	emit_signal("updateHint", "Use", false)
	emit_signal("updateHint", "Gift", false)
	return .dropHeldItem(strength)

func takeItem(item: Item) -> bool:
	var ret = .takeItem(item)

	emit_signal("updateHint", "Throw", true)

	if ret and item.is_in_group("usable"):
		emit_signal("updateHint", "Use", true)

	return ret
