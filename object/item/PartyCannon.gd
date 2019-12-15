extends "res://object/item/Item.gd"

onready var particles: CPUParticles = $"HeartParticles"

func _ready():
	._ready()

	add_to_group("usable")

func useItem(character: RigidBody):
	particles.emitting = true
