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
		state_machine.set_state('Attack')
	
	if state_machine.get_state_name() != 'Attack':
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

func _on_state_changed(new_state: Object):
	if new_state.name == 'Attack':
		if _interaction_attempt():
			state_machine.set_state('Idle')
	._on_state_changed(new_state)


func _on_hp_changed(new_hp: int) -> void:
	._on_hp_changed(new_hp)
	
	EVENTS.emit_signal("character_hp_changed", hp)
