extends "res://object/item/Item.gd"

func _ready():
	._ready()

	add_to_group("usable")

func useItem(character: RigidBody):
	var hatHold: Position3D = character.get_node_or_null("Rig/HatHold")

	if hatHold.get_child_count() > 0:
		var oldHat = hatHold.get_child(0)
		var oldPos = character.global_transform.origin
		Util.reparent(oldHat, character.get_node("../.."))
		oldHat.global_transform.origin = oldPos + Vector3(0, 0.5, 0)
		oldHat.add_to_group("item")

	character.dropHeldItem()
	translation = Vector3(0, 0, 0)
	rotation = Vector3(0, 0, 0)
	Util.reparent(self, hatHold)

	remove_from_group("item")
