extends StaticBody2D

onready var animated_sprite = $AnimatedSprite
onready var colision_shape = $CollisionShape2D

enum STATE {
	IDLE,
	OPENING,
	OPEN
}

var state : int = STATE.IDLE

func interact() -> void:
	if state != STATE.IDLE:
		return
	state = STATE.OPENING
	animated_sprite.play('Open')


func _on_AnimatedSprite_animation_finished():
	if animated_sprite.get_animation() == 'Open':
		state = STATE.OPEN
