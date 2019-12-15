extends Character
class_name NPC

var rng: RandomNumberGenerator
var wants: String = ""

onready var npcItemDetector: Area = $"Rig/NPCItemDetector"
onready var heartParticles: CPUParticles = $"HeartParticles"
onready var happyTimer: Timer = $"HappyTimer"

onready var raycast: RayCast = $"Rig/RayCast"
var moveDir: Vector3
var moveDuration: float = 0

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	maybeGenerateNewWant()

	#warning-ignore:return_value_discarded
	npcItemDetector.connect("body_entered", self, "handleItemEnter")
	#warning-ignore:return_value_discarded
	happyTimer.connect("timeout", self, "maybeGenerateNewWant")

func maybeGenerateNewWant():
	if rng.randf() < 0.5:
		generateNewWant()
	else:
		happyTimer.start(rng.randf_range(60, 180))

func generateNewWant():
	if wants != "":
		removeWant()

	#warning-ignore:return_value_discarded
	dropHeldItem()

	heartParticles.emitting = false

	var itemList = $"/root/ItemList" as Spatial

	var itemID = rng.randi_range(0, itemList.get_child_count() - 1)

	var itemInstance = (itemList.get_child(itemID) as Item).duplicate()
	itemInstance.name = "WantedItemIndicator"
	itemInstance.translation = Vector3(0, 1.2, 0)
	itemInstance.scale_object_local(Vector3(0.5, 0.5, 0.5))
	itemInstance.sleeping = true
	# Items not in the "item" group can not be picked up
	itemInstance.remove_from_group("item")
	itemInstance.get_node("Mesh").set_material_override(preload("res://object/palette-highlight.material"))
	add_child(itemInstance)

	wants = itemInstance.itemName

func makeHappy(item: Item) -> bool:
	if not Util.isValidItem(item) or Util.isHeld(item):
		return false

	removeWant()

	#warning-ignore:return_value_discarded
	takeItem(item)

	heartParticles.emitting = true
	heartParticles.amount = 6
	heartParticles.one_shot = false

	happyTimer.start(rng.randf_range(10, 180))

	return true

func removeWant():
	wants = ""

	var wantIndicator = get_node_or_null("WantedItemIndicator")
	if wantIndicator:
		wantIndicator.get_parent().remove_child(wantIndicator)

func _physics_process(delta):
	if raycast.is_colliding():
		moveDuration *= 0.5

	moveDuration -= delta
	if moveDuration <= 0:
		moveDuration = rng.randf_range(0.5, 10) + rng.randf_range(0.5, 3)

		if rng.randf() < 0.4:
			moveDir = Vector3(0, 0, 0)
		else:
			moveDir = Vector3(rng.randf() - 0.5, 0, rng.randf() - 0.5).normalized()

	apply_central_impulse(delta * 80 * moveDir)

func handleItemEnter(arg: Item):
	if Util.isValidItem(arg) and arg.itemName == wants:
		if not Util.isHeld(arg):
			call_deferred("makeHappy", arg)
		else:
			heartParticles.emitting = true
			heartParticles.amount = 2
			heartParticles.one_shot = true
