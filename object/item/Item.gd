extends RigidBody
class_name Item

export(String) var itemName

func _ready():
	add_to_group("item")
