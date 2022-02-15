extends KinematicBody2D
class_name Actor

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
onready var attack_hitbox = $AttackHitbox


var dir_dict: Dictionary = {
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT,
	"Down": Vector2.DOWN,
	"Up": Vector2.UP,
}


var speed := 300.0
var moving_direction := Vector2.ZERO setget set_moving_direction, get_moving_direction
var facing_direction := Vector2.DOWN setget set_facing_direction, get_facing_direction

signal facing_direction_changed
signal moving_direction_changed

#### ACCESSORS ####
 
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
func _ready():
	var __ = state_machine.connect("state_changed", self, "_on_state_changed")
	__ = connect("facing_direction_changed", self, "_on_facing_direction_changed")
	__ = connect("moving_direction_changed", self, "_on_moving_direction_changed")
	__ = animated_sprite.connect("animation_finished", self, "_on_AnimatedSprite_animation_finished")
	__ = animated_sprite.connect("frame_changed", self, "_on_AnimatedSprite_frame_changed")
	

#### LOGIC ####

# Update the animation based on the current state and the facing direction
func _update_animation() -> void:
	var dir_name = _find_dir_name(facing_direction)
	var state_name = state_machine.get_state_name()
	
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

func attack_effect() -> void:
	var bodies_array = attack_hitbox.get_overlapping_bodies()
	
	for body in bodies_array:
		if body.has_method('destroy'):
			body.destroy()

# Update the rotation of the attack hitbox based on the facing direction
func _update_attack_hitbox_direction() -> void:
	var angle = facing_direction.angle()
	attack_hitbox.set_rotation_degrees(rad2deg(angle) - 90)


func _change_state_from_moving_direction() -> void:
	if moving_direction == Vector2.ZERO:
		state_machine.set_state('Idle')
	else:
		state_machine.set_state('Move')

#### SIGNAL RESPONSES ####
func _on_state_changed(new_state: Object):
	_update_animation()

func _on_AnimatedSprite_animation_finished():
	if 'Attack'.is_subsequence_of(animated_sprite.get_animation()):
		_change_state_from_moving_direction()

func _on_facing_direction_changed():
	# prevent mutiple attacks while spamming direction during attack animation
	if state_machine.get_state_name() == 'Attack': 
		return
	_update_animation()
	_update_attack_hitbox_direction()


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


func _on_AnimatedSprite_frame_changed():
	if 'Attack'.is_subsequence_of(animated_sprite.get_animation()):
		if animated_sprite.get_frame() == 1:
			attack_effect()