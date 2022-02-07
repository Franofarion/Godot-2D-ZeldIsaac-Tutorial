extends KinematicBody2D

onready var animated_sprite = get_node("AnimatedSprite")

export var speed := 300.0
var direction = Vector2.ZERO

func _process(delta: float) -> void:
	move_and_slide(direction * speed)

func _input(event: InputEvent) -> void:
	# direction compute
	direction.x = int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left'))
	direction.y = int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	
	# slow down diagonal movement
	direction = direction.normalized()
	
	# animation setter
	match(direction):
		Vector2.ZERO:
			animated_sprite.stop()
			animated_sprite.set_frame(0)
		Vector2.RIGHT: animated_sprite.play('MoveRight')
		Vector2.LEFT: animated_sprite.play('MoveLeft')
		Vector2.DOWN: animated_sprite.play('MoveDown')
		Vector2.UP: animated_sprite.play('MoveUp')
		
