extends Actor
class_name Character

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("item_used", self, "_on_item_used")

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

	_update_state()

func _update_state() -> void:
	if not state_machine.get_state_name() in ["Attack", "Parry"]:
		if Input.is_action_pressed("block"):
			state_machine.set_state("Block")
		elif moving_direction == Vector2.ZERO:
				state_machine.set_state('Idle')
		else:
				state_machine.set_state('Move')

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
		elif state_machine.previous_state == $StateMachine/Attack:
			_update_state()
	._on_state_changed(new_state)


func _on_hp_changed(new_hp: int) -> void:
	._on_hp_changed(new_hp)

	EVENTS.emit_signal("character_hp_changed", hp)


func _on_mp_changed(new_mp: int) -> void:
	._on_mp_changed(new_mp)

	EVENTS.emit_signal("character_mp_changed", mp)


func _on_item_used(item_data: ItemData) -> void:
	if item_data.damage_type == Constants.DAMAGE_TYPE.HP:
		set_hp(hp - item_data.damage)
	if item_data.damage_type == Constants.DAMAGE_TYPE.MP:
		set_mp(mp - item_data.damage)
