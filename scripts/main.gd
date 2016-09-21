
extends Node

var combat_scn = preload("res://scenes/CombatNode.tscn")
var management_scn = preload("res://scenes/ManagementNode.tscn")
var scn

var units_vector = []

# Unit class - for instancing an enemy or ally
class unit:
	var id # Unit ID in the character database
	var name # Unit's name
	var wpn_vector = [] # Array containing the unit's available weapons, be it natural or not
	var item_vector = [] # Array containing the unit's available items


func _ready():
	var level = combat_scn.instance()

	level.set_name("level")
	add_child(level)


# Assumes it will always be changing scenes, not reloading the same
func set_level(mode):
	if mode == "combat":
		scn = combat_scn
		units_vector = get_node("level").active_units
	elif mode == "management":
		scn = management_scn
		units_vector = get_node("level").allies_vector

	var level = scn.instance()
	get_node("level").set_name("old")
	level.set_name("level")
	if mode == "combat":
		level.allies_vector = units_vector
	else:
		level.active_units = units_vector
	add_child(level)
	get_node("old").queue_free()