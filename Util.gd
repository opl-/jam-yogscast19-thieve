class_name Util

static func reparent(thing: Node, parent: Node):
	assert(thing != null)
	assert(parent != null)

	thing.get_parent().remove_child(thing)
	parent.add_child(thing)
	thing.set_owner(parent)

static func isValidItem(node: Node):
	return node and node is Item and node.is_in_group("item")

static func isHeld(node: Spatial) -> bool:
	return node and node.get_parent() and node.get_parent().name == "Hold"
