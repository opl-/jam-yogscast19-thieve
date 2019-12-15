extends Position3D

export(float) var chance = 0.4

func _ready():
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	if rng.randf() >= chance:
		return

	var itemList = $"/root/ItemList" as Spatial

	var itemID = rng.randi_range(0, itemList.get_child_count() - 1)

	var itemInstance = (itemList.get_child(itemID) as Item).duplicate() as Item
	itemInstance.translation = Vector3(0, 0, 0)

	add_child(itemInstance)
