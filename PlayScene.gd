extends Spatial

var currentScene: Spatial
onready var cameraLook: Position3D = $"CameraLook"
var viewportResized = false
var viewport: Viewport

func _ready():
	$"quit/ConfirmationDialog".connect("confirmed", self, "quit")

func _enter_tree():
	viewport = $"/root"
	viewport.connect("size_changed", self, "handle_resize")
	handle_resize()

	# Create a global instance of ItemList
	var itemList = (preload("res://object/item/ItemList.tscn") as PackedScene).instance() as Spatial
	itemList.pause_mode = Node.PAUSE_MODE_STOP
	itemList.visible = false
	$"/root".call_deferred("add_child", itemList)

	currentScene = (preload("res://map/city.tscn") as PackedScene).instance()
	call_deferred("add_child", currentScene)

	call_deferred("spawnPlayer")

func spawnPlayer():
	var player = (preload("res://object/entity/Player.tscn") as PackedScene).instance() as Node
	add_child(player)

	var playerSpawn = currentScene.get_node("PlayerSpawn") as Position3D
	player.translate(playerSpawn.global_transform.origin)

	var cameraRemote = RemoteTransform.new()
	cameraRemote.name = "CameraRemote"
	cameraRemote.remote_path = cameraLook.get_path()
	cameraRemote.update_rotation = false
	player.get_node("Character").add_child(cameraRemote)

func _input(event):
	if Input.is_action_just_pressed("ui_exit"):
		$"quit/ConfirmationDialog".popup_centered()

func quit():
	get_tree().quit()

func handle_resize():
	# Prevent enless signal loops
	if viewportResized:
		viewportResized = false
		return

	viewportResized = true
	viewport.size = viewport.size / 2
