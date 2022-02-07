extends KinematicBody2D

export var SPEED := 300.0
var direction = Vector2.ZERO

var h_movement: int = 0
var v_movement: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	move_and_slide(direction * SPEED)

func _input(event: InputEvent) -> void:
	direction.x = int(event.is_action_pressed('ui_right')) - int(event.is_action_pressed('ui_left'))
	direction.y = int(event.is_action_pressed('ui_down')) - int(event.is_action_pressed('ui_up'))

