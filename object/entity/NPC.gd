extends Character

var rng: RandomNumberGenerator
var wants: String

onready var raycast: RayCast = $"RayCast"
var moveDir: Vector3
var moveDuration: float = 0

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	if rng.randf() < 0.2:
		generateNewWant()

func generateNewWant():
	var itemList = $"/root/ItemList" as Spatial

	var itemID = rng.randi_range(0, itemList.get_child_count() - 1)

	var itemInstance = (itemList.get_child(itemID) as Item).duplicate()
	itemInstance.translation = Vector3(0, 1.2, 0)
	itemInstance.scale_object_local(Vector3(0.5, 0.5, 0.5))
	itemInstance.sleeping = true
	itemInstance.remove_from_group("item")
	itemInstance.get_node("Mesh").set_material_override(preload("res://object/palette-highlight.material"))
	add_child(itemInstance)

	wants = itemInstance.itemName

	print("i want ", wants)

func _physics_process(delta):
	if raycast.is_colliding():
		moveDuration *= 0.5

	moveDuration -= delta
	if moveDuration <= 0:
		moveDuration = rng.randf_range(0.5, 10) + rng.randf_range(0.5, 3)
		moveDir = Vector3(rng.randf() - 0.5, 0, rng.randf() - 0.5).normalized()

	apply_central_impulse(delta * 80 * moveDir)
