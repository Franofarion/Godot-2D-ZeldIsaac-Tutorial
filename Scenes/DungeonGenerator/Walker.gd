extends Node
class_name Walker

var max_steps : int = 0
var nb_steps : int = 0

var cell = Vector2.INF setget set_cell

var sub_walkers_steps := Array()

signal moved(cell)
signal arrived
signal sub_walker_creation

#### ACCESSORS ####
func is_class(value: String): return value == "Walker" or .is_class(value)
func get_class() -> String: return "Walker"

func set_cell(value: Vector2) -> void:
	if value != cell:
		cell = value
		emit_signal("moved", cell)

#### BUILT-IN ####
func _init(_cell: Vector2, _max_steps: int, nb_sub_walkers: int) -> void:
	cell = _cell
	max_steps = _max_steps
	choose_subwalkers_steps(nb_sub_walkers)

func _ready() -> void:
	pass


### VIRTUALS ###




#### LOGIC ####

func step(accesible_cells: Array) -> void:
	if accesible_cells.empty():
		emit_signal("arrived")
		return

	nb_steps += 1
	var new_cell = choose_cell(accesible_cells)

	set_cell(new_cell)

	if nb_steps in sub_walkers_steps:
		sub_walkers_steps.erase(nb_steps)
		emit_signal("sub_walker_creation", cell, 4, 0)

	if nb_steps >= max_steps:
		emit_signal("arrived")


func choose_cell(accesible_cells: Array) -> Vector2:
	var rdm_id = randi() % accesible_cells.size()
	return accesible_cells[rdm_id]


func choose_subwalkers_steps(nb_walkers: int) -> void:
	var steps_array = range(max_steps)
	steps_array.shuffle()

	for _i in range(nb_walkers):
		if steps_array.empty():
			break
		var step = steps_array.pop_front()
		sub_walkers_steps.append(step)

### INPUTS ###




#### SIGNAL RESPONSES ####
