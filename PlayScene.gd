extends Spatial

var rng: RandomNumberGenerator

var currentScene: Spatial
onready var cameraLook: Position3D = $"CameraLook"
var viewportResized = false
var viewport: Viewport

func _ready():
	$"quit/ConfirmationDialog".connect("confirmed", self, "quit")

	viewport = $"/root"
	viewport.connect("size_changed", self, "handle_resize")
	handle_resize()

	$"/root".connect("ready", self, "initGlobal")

func initGlobal():
	rng = RandomNumberGenerator.new()
	rng.randomize()

	# Create a global instance of ItemList
	var itemList = (preload("res://object/item/ItemList.tscn") as PackedScene).instance() as Spatial
	itemList.name = "ItemList"
	itemList.pause_mode = Node.PAUSE_MODE_STOP
	itemList.visible = false
	$"/root".add_child(itemList)

	currentScene = (preload("res://map/city.tscn") as PackedScene).instance()
	add_child(currentScene)

	spawnNPCs()
	spawnPlayer()

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

func spawnNPCs():
	var paths = currentScene.get_node("Paths")

	for i in range(30):
		var path: Curve3D = (paths.get_child(rng.randi_range(0, paths.get_child_count() - 1)) as Path).curve
		var pos := path.interpolate(rng.randi_range(0, path.get_point_count() - 1), rng.randf())

		var npc = (preload("res://object/entity/NPC.tscn") as PackedScene).instance()
		add_child(npc)
		npc.global_transform.origin = pos

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
