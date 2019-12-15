extends RigidBody
class_name Item

#warning-ignore:unused_class_variable
export(String) var itemName

var lastHolder: RigidBody = null

func _ready():
	add_to_group("item")

func useItem(character: RigidBody):
	pass
