extends StateMachine
class_name WanderState

export var min_wander_distance := 50.0
export var max_wander_distance := 200.0

func _ready():
	var __ = $Wait.connect("wait_time_finished", self, "_on_Wait_wait_time_finished")
	__ = owner.connect("move_path_finished", self, "_on_Enemy_move_path_finished")

#### VIRTUALS ####

#### LOGIC ####

func _generate_random_destination() -> Vector2:
	var angle = deg2rad(rand_range(0.0, 360.0))
	var direction = Vector2(cos(angle), sin(angle))
	var distance = rand_range(min_wander_distance, max_wander_distance)
	
	return owner.global_position + direction * distance

func _find_wander_destination() -> Vector2:
	var pos = _generate_random_destination()
	if owner.pathfinder != null:
		if !owner.pathfinder.is_position_valid(pos):
			# doing recursive instead of while loop
			return _find_wander_destination()
	return pos


#### SIGNAL RESPONSES ####

func _on_Wait_wait_time_finished() -> void:
	owner.update_move_path(_find_wander_destination())
	set_state("GoTo")

func _on_Enemy_move_path_finished() -> void:
	if is_current_state():
		set_state("Wait")
