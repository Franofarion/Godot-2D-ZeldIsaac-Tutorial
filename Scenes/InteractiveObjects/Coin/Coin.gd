extends Node2D

onready var area = $Area2D
onready var coin_sprite = $CoinSprite
onready var shadow_sprite = $ShadowSprite
onready var particule = $Particles2D
onready var audio_stream = $AudioStreamPlayer2D
onready var animation_player = $AnimationPlayer

enum STATE {
	IDLE,
	FOLLOW,
	COLLECT
}

var speed : float = 400.0
var state : int = STATE.IDLE
var target : Node2D = null

#### BUILT-IN ####

func _ready():
	animation_player.play("Wave")

func _physics_process(delta: float) -> void:
	if state != STATE.IDLE:
		var target_pos = target.get_position()
		var spd = speed * delta
		
		if position.distance_to(target_pos) < spd:
			position = target_pos
			collect()
		else:
			position = position.move_toward(target_pos, spd)

#### LOGIC ####

func collect() -> void:
	if state != STATE.COLLECT:
		state = STATE.COLLECT
		coin_sprite.set_visible(false)
		shadow_sprite.set_visible(false)
		particule.set_emitting(true)
		audio_stream.play()
		
		EVENTS.emit_signal("coin_collected")
		
		yield(audio_stream, "finished")
		queue_free()

#### SIGNAL RESPONSES ####

func _on_Area2D_body_entered(body: Node):
	if state == STATE.IDLE:
		state = STATE.FOLLOW
		target = body
		animation_player.stop()


func _on_Timer_timeout():
	if state == STATE.IDLE:
		coin_sprite.play('Rotation')
		shadow_sprite.play('Rotation')
	


func _on_CoinSprite_animation_finished():
	if coin_sprite.get_animation() == 'Rotation':
		coin_sprite.play('Idle')
		shadow_sprite.play('Idle')
