extends Actor
class_name Character

#### ACCESSORS ####


#### BUILT-IN ####

func _input(_event: InputEvent) -> void:
	# moving_direction compute
	var dir = Vector2(
		int(Input.is_action_pressed('ui_right')) - int(Input.is_action_pressed('ui_left')),
		int(Input.is_action_pressed('ui_down')) - int(Input.is_action_pressed('ui_up'))
	)
	# .normalized => slow down diagonal movement
	set_moving_direction(dir.normalized())
	
	if Input.is_action_pressed('ui_accept'):
		set_state(STATE.ATTACK)
	
	if state != STATE.ATTACK:
		_change_state_from_moving_direction()

#### LOGIC ####

func _interaction_attempt() -> bool:
	var bodies_array = attack_hitbox.get_overlapping_bodies()
	
	for body in bodies_array:
		if body.has_method('interact'):
			body.interact()
			return true
	
	return false

#### SIGNAL RESPONSES ####

func _on_state_changed():
	if state == STATE.ATTACK:
		if _interaction_attempt():
			set_state(STATE.IDLE)
	._on_state_changed()
