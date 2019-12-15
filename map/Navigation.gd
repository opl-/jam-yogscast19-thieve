extends Navigation

func _ready():
	var pos = self.get_closest_point($"../PlayerSpawn".global_transform.origin)

	print($"../PlayerSpawn".global_transform.origin, pos)
	$"../Indicator".translate(pos)
