extends Actor
class_name Enemy

onready var behaviour_tree = $BehaviourTree
onready var chase_area = $ChaseArea
onready var attack_area = $AttackArea
onready var path_line = $PathLine

var target : Node2D = null
var path : Array = []

var pathfinder : Pathfinder = null

var target_in_chase_area : bool = false setget set_target_in_chase_area
var target_in_attack_area : bool = false setget set_target_in_attack_area

signal target_in_chase_area_changed
signal target_in_attack_area_changed
signal move_path_finished

#### ACCESSORS ####

func set_target_in_chase_area(value: bool) -> void:
	if value != target_in_chase_area:
		target_in_chase_area = value
		emit_signal("target_in_chase_area_changed", target_in_chase_area)

func set_target_in_attack_area(value: bool) -> void:
	if value != target_in_attack_area:
		target_in_attack_area = value
		emit_signal("target_in_attack_area_changed", target_in_attack_area)


#### BUILT-IN ####

func _ready():
	var __ = chase_area.connect("body_entered", self, "_on_ChaseArea_body_entered")
	__ = chase_area.connect("body_exited", self, "_on_ChaseArea_body_exited")
	__ = attack_area.connect("body_entered", self, "_on_AttackArea_body_entered")
	__ = attack_area.connect("body_exited", self, "_on_AttackArea_body_exited")
	__ = connect("target_in_chase_area_changed", self, "_on_target_in_chase_area_changed")
	__ = connect("target_in_attack_area_changed", self, "_on_target_in_attack_area_changed")
	__ = state_machine.connect("state_changed", self, "_on_StateMachine_state_changed")
	__ = $BehaviourTree/Attack/Cooldown.connect("timeout", self, "_on_attack_cooldown_finished")
	
	path_line.set_as_toplevel(true)

#### LOGIC ####

func _update_target() -> void:
	if !target_in_chase_area && !target_in_attack_area:
		target = null

func _update_behaviour_state() -> void:
	if target_in_attack_area:
		if $BehaviourTree/Attack.is_cooldown_running():
			behaviour_tree.set_state("Inactive")
			path = []
		else:
			behaviour_tree.set_state("Attack")
	
	elif target_in_chase_area:
		behaviour_tree.set_state("Chase")
	
	else: 
		behaviour_tree.set_state("Wander")

func update_move_path(dest: Vector2) -> void:
	if pathfinder == null:
		path = [dest]
	else:
		path = pathfinder.find_path(global_position, dest)
	
	if path_line.is_visible():
		path_line.set_points(path)

func move_along_path(delta: float) -> void:
	if path.empty():
		return
	
	var dir = global_position.direction_to(path[0])
	var dist = global_position.distance_to(path[0])
	
	set_moving_direction(dir)
	
	if dist <= speed * delta:
		var __ = move_and_collide(dir * dist)
		path.remove(0)
		
		if path.empty():
			emit_signal("move_path_finished")
	else:
		var __ = move_and_collide(dir * speed * delta)

func can_attack() -> bool:
	return !$BehaviourTree/Attack.is_cooldown_running() && target_in_attack_area

#### SIGNAL RESPONSES #### 

func _on_ChaseArea_body_entered(body: Node2D):
	if body is Character:
		set_target_in_chase_area(true)
		target = body

func _on_ChaseArea_body_exited(body: Node2D):
	if body is Character:
		set_target_in_chase_area(false)

func _on_AttackArea_body_entered(body: Node2D):
	if body is Character:
		set_target_in_attack_area(true)
		target = body

func _on_AttackArea_body_exited(body: Node2D):
	if body is Character:
		set_target_in_attack_area(false)

func _on_target_in_chase_area_changed(_value: bool):
	_update_target()
	_update_behaviour_state()

func _on_target_in_attack_area_changed(_value: bool):
	_update_target()
	if target_in_attack_area:
		_update_behaviour_state()

# Overided method
func _on_moving_direction_changed():
	face_direction(moving_direction)

func _on_StateMachine_state_changed(state: State) -> void:
	if state_machine == null:
		return
	
	if state_machine.previous_state == $StateMachine/Attack or state_machine.previous_state == $StateMachine/Hurt:
		_update_behaviour_state()
	
	if state.name == "Attack":
		face_position(target.global_position)

func _on_attack_cooldown_finished() -> void:
	_update_behaviour_state()
