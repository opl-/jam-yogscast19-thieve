class_name Util

static func reparent(thing: Node, parent: Node):
	assert(thing != null)
	assert(parent != null)

	thing.get_parent().remove_child(thing)
	parent.add_child(thing)
	thing.set_owner(parent)
