extends State
class_name ActorMoveState

func update(delta) -> void:
	var __ = owner.move_and_slide(owner.moving_direction * owner.speed)
