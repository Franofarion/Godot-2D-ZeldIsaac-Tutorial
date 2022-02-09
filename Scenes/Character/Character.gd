extends KinematicBody2D

onready var animated_sprite = get_node("AnimatedSprite")

enum STATE {
	IDLE,
	MOVE,
	ATTACK 
}

var dir_dict: Dictionary = {
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT,
	"Down": Vector2.DOWN,
	"Up": Vector2.UP,
}

var state : int = STATE.IDLE setget set_state, get_state

var speed := 300.0
var moving_direction := Vector2.ZERO setget set_moving_direction, get_moving_direction
var facing_direction := Vector2.DOWN setget set_facing_direction, get_facing_direction

signal state_changed
signal facing_direction_changed
signal moving_direction_changed

#### ACCESSORS ####

func set_state(value: int) -> void:
	if state != value:
		state = value
		emit_signal('state_changed')

func get_state() -> int:
	return state

func set_facing_direction(value: Vector2) -> void:
	if facing_direction != value:
		facing_direction =  value
		emit_signal('facing_direction_changed')

func get_facing_direction() -> Vector2:
	return facing_direction

func set_moving_direction(value: Vector2) -> void:
	if moving_direction != value:
		moving_direction =  value
		emit_signal('moving_direction_changed')

func get_moving_direction() -> Vector2:
	return moving_direction

#### BUILT-IN ####
func _process(_delta: float) -> void:
	var __ = move_and_slide(moving_direction * speed)

func _input(_event: InputEvent) -> void:
	# moving_direction compute
	var dir = Vector2(
		int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left')),
		int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	)
	# .normalized => slow down diagonal movement
	set_moving_direction(dir.normalized())
	
	if Input.is_action_just_pressed('ui_accept'):
		set_state(STATE.ATTACK)
	
	if state != STATE.ATTACK:
		if moving_direction == Vector2.ZERO:
			set_state(STATE.IDLE)
		else:
			set_state(STATE.MOVE)

#### LOGIC ####

# Update the animation based on the current state and the facing_direction
func _update_animation() -> void:
	var dir_name = _find_dir_name(facing_direction)
	var state_name = ''
	
	match(state):
		STATE.IDLE: state_name = 'Idle'
		STATE.MOVE: state_name = 'Move'
		STATE.ATTACK: state_name = 'Attack'
	
	animated_sprite.play(state_name + dir_name)

# Find the name of the given direction and returns it as a string
func _find_dir_name(dir: Vector2) -> String:
	var dir_value_array = dir_dict.values()
	var dir_index = dir_value_array.find(dir)
	
	
	if dir_index == -1:
		return ""
	var dir_keys_array = dir_dict.keys()
	var dir_key = dir_keys_array[dir_index]
	
	return dir_key


#### SIGNAL RESPONSES ####

func _on_AnimatedSprite_animation_finished():
	if 'Attack'.is_subsequence_of(animated_sprite.get_animation()):
		set_state(STATE.IDLE)
		

func _on_state_changed():
	_update_animation()


func _on_facing_direction_changed():
	_update_animation()


func _on_moving_direction_changed():
	if moving_direction == Vector2.ZERO or moving_direction == facing_direction:
		return
	
	var sign_dir = Vector2(sign(moving_direction.x), sign(moving_direction.y))
	
	# if the movement is not diagonal
	if sign_dir == moving_direction:
		set_facing_direction(moving_direction)
	# if the movement is diagonal
	else:
		if sign_dir.x == moving_direction.x:
			set_facing_direction(Vector2(0, sign_dir.y))
		else:
			set_facing_direction(Vector2(sign_dir.x, 0))
			
