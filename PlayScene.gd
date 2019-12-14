extends Spatial

var currentScene: Spatial
onready var cameraLook: Position3D = $"CameraLook"

func _enter_tree():
	currentScene = (preload("res://map/city.tscn") as PackedScene).instance()
	call_deferred("add_child", currentScene)

	call_deferred("spawnPlayer")

func spawnPlayer():
	var player = (preload("res://object/Player.tscn") as PackedScene).instance() as Node
	add_child(player)

	var playerSpawn = currentScene.get_node("PlayerSpawn") as Position3D
	print(playerSpawn.global_transform.origin)
	player.translate(playerSpawn.global_transform.origin)

	var cameraRemote = RemoteTransform.new()
	cameraRemote.name = "CameraRemote"
	cameraRemote.remote_path = cameraLook.get_path()
	cameraRemote.update_rotation = false
	player.add_child(cameraRemote)
