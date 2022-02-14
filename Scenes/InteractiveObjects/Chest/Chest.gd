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

func _spawn_content() -> void:
	print(String(position))
	EVENTS.emit_signal("spawn_coin", position)

func _on_AnimatedSprite_animation_finished():
	if animated_sprite.get_animation() == 'Open':
		state = STATE.OPEN
		_spawn_content()
