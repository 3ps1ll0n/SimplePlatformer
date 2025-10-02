extends Node2D
@onready var projectile_manager: Node2D = $"../../ProjectileManager"
@onready var player: CharacterBody2D = $".."


enum SPELL_LIST {
	BIG_SLASH,
	MAGIC_KNIFE,
	FIRE_BLAST,
	NONE
}

var selected_spell : SPELL_LIST = SPELL_LIST.BIG_SLASH

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_selected_spell() -> String:
	match selected_spell:
		SPELL_LIST.BIG_SLASH:
			return "BIG_SLASH"
	return "NONE"


func cast_spell():
	var spell = preload("res://Scenes/Spell/Big_Slash.tscn").instantiate()
	spell.position = global_position + (player.get_node("AttackPoint").position * 1.75)
	spell.set_direction(player.get_attack_direction().x)
	projectile_manager.add_child(spell)
