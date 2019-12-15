extends RigidBody
class_name Item

#warning-ignore:unused_class_variable
export(String) var itemName
#warning-ignore:unused_class_variable
export(bool) var wearable = false

func _ready():
	add_to_group("item")
