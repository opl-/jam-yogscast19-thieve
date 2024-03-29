extends Spatial

var rng: RandomNumberGenerator

var currentScene: Spatial
onready var cameraLook: Position3D = $"CameraLook"
var viewportResized = false
var viewport: Viewport

onready var scoreLabel: Label = $"UI/Status/Score/Label"
onready var timerLabel: Label = $"UI/Status/Timer/Label"

onready var hintThrowLabel: Control = $"UI/Hints/Throw/Label"
onready var hintMove: Control = $"UI/Hints/Move"

var runDuration: int = 0
var runStart: int

func _ready():
	#warning-ignore:return_value_discarded
	$"quit/ConfirmationDialog".connect("confirmed", self, "quit")
	#warning-ignore:return_value_discarded
	$"quit/ConfirmationDialog".connect("about_to_show", self, "pause")
	#warning-ignore:return_value_discarded
	$"quit/ConfirmationDialog".connect("hide", self, "unpause")

	OS.set_window_size(OS.get_screen_size())

	viewport = $"/root"
	#warning-ignore:return_value_discarded
	viewport.connect("size_changed", self, "handle_resize")
	handle_resize()

	#warning-ignore:return_value_discarded
	$"/root".connect("ready", self, "initGlobal")

func _process(delta):
	var time = runDuration + (0 if runStart < 0 else OS.get_system_time_msecs() - runStart)

	timerLabel.text = str(floor(time / 60000)).pad_zeros(2) + ":" + str(floor((time % 60000) / 1000)).pad_zeros(2) + "." + str(time % 1000).pad_zeros(3)

func initGlobal():
	runStart = OS.get_system_time_msecs()
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
	var playerCharacter = player.get_node("Character")

	var playerSpawn = currentScene.get_node("PlayerSpawn") as Position3D
	player.translate(playerSpawn.global_transform.origin)

	var cameraRemote = RemoteTransform.new()
	cameraRemote.name = "CameraRemote"
	cameraRemote.remote_path = cameraLook.get_path()
	cameraRemote.update_rotation = false
	playerCharacter.add_child(cameraRemote)

	playerCharacter.add_to_group("player")

	playerCharacter.connect("scoreChanged", self, "updateScore")
	playerCharacter.connect("updateHint", self, "updateHint")

	var moveHintTimer = Timer.new()
	moveHintTimer.connect("timeout", self, "hideMoveHint")
	moveHintTimer.start(60)
	add_child(moveHintTimer)

func spawnNPCs():
	var paths = currentScene.get_node("Paths")

	#warning-ignore:unused_variable
	for i in range(30):
		var path: Curve3D = (paths.get_child(rng.randi_range(0, paths.get_child_count() - 1)) as Path).curve
		var pos := path.interpolate(rng.randi_range(0, path.get_point_count() - 1), rng.randf())

		var npc = (preload("res://object/entity/NPC.tscn") as PackedScene).instance()
		add_child(npc)
		npc.global_transform.origin = pos

#warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("ui_exit"):
		$"quit/ConfirmationDialog".popup_centered()

func quit():
	get_tree().quit()

func pause():
	handlePause(true)
	get_tree().paused = true

func unpause():
	handlePause(false)
	get_tree().paused = false

func handle_resize():
	# Prevent enless signal loops
	if viewportResized:
		viewportResized = false
		return

	viewportResized = true
	viewport.size = viewport.size / 2

func updateScore(score: int):
	scoreLabel.text = str(score)

func updateHint(name: String, show: bool):
	# Special case
	if name == "Gift":
		hintThrowLabel.text = "GIFT" if show else "THROW (HOLD)"
		return

	var hint = get_node_or_null("UI/Hints/" + name)
	print(hint, name, show)

	if not hint:
		return

	hint.visible = show

func hideMoveHint():
	hintMove.visible = false

func handlePause(paused: bool):
	if paused:
		runDuration += OS.get_system_time_msecs() - runStart
		runStart = -1
	else:
		runStart = OS.get_system_time_msecs()
