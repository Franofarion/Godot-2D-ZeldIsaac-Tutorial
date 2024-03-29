extends StaticBody2D

onready var state_machine = $StateMachine
onready var animated_sprite = $AnimatedSprite
onready var colision_shape = $CollisionShape2D


func interact() -> void:
	if state_machine.get_state_name() == 'Idle':
		state_machine.set_state('Open')
		animated_sprite.play('Open')


func _on_AnimatedSprite_animation_finished():
	if animated_sprite.get_animation() == 'Open':
		state_machine.set_state('Opened')
		$DropperBehavior.drop_item()
