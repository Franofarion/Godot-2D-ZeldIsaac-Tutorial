extends KinematicBody2D

onready var animated_sprite = get_node("AnimatedSprite")

var dir_dict: Dictionary = {
	"Left": Vector2.LEFT,
	"Right": Vector2.RIGHT,
	"Down": Vector2.DOWN,
	"Up": Vector2.UP,
}

var speed := 300.0
var moving_direction := Vector2.ZERO
var facing_direction := Vector2.DOWN

var is_attacking := false
var is_moving := false

func _process(_delta: float) -> void:
	var __ = move_and_slide(moving_direction * speed)

func _input(_event: InputEvent) -> void:
	# moving_direction compute
	moving_direction.x = int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left'))
	moving_direction.y = int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	# slow down diagonal movement
	moving_direction = moving_direction.normalized()
	
	if moving_direction != Vector2.ZERO:
		facing_direction = moving_direction
	
	if Input.is_action_just_pressed('ui_accept'):
		is_attacking = true
	
	var dir_name = _find_dir_name(moving_direction)
	
	if is_attacking:
		# Attack animation
		var anim_name = "Attack" + dir_name
		if animated_sprite.get_sprite_frames().has_animation(anim_name):
			animated_sprite.play(anim_name)
	else:
		# Idle animation
		if moving_direction == Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.set_frame(0)
			
		# Move animation
		else:
			is_moving = true
			var anim_name = "Move" + dir_name
			if animated_sprite.get_sprite_frames().has_animation(anim_name):
				animated_sprite.play(anim_name)
	
	

func _find_dir_name(dir: Vector2) -> String:
	var dir_value_array = dir_dict.values()
	var dir_index = dir_value_array.find(dir)
	
	
	if dir_index == -1:
		return ""
	var dir_keys_array = dir_dict.keys()
	var dir_key = dir_keys_array[dir_index]
	
	return dir_key



func _on_AnimatedSprite_animation_finished():
	if 'Attack'.is_subsequence_of(animated_sprite.get_animation()):
		is_attacking = false
		
	var dir_name = _find_dir_name(facing_direction)
	
	animated_sprite.set_animation('Move' + dir_name)
	animated_sprite.stop()
	animated_sprite.set_frame(0)
		
