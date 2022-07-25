extends YSort

onready var pathfinder = $Tilemap/Pathfinder


func _ready() -> void:
	var __ = EVENTS.connect("actor_died", self, "_on_EVENTS_actor_died")

	OS.window_fullscreen = true
	OS.window_maximized = true

	var enemies = get_tree().get_nodes_in_group('Enemy')
	for enemy in enemies:
		enemy.pathfinder = pathfinder

func _on_EVENTS_actor_died(actor: Actor) -> void:
	if actor is Enemy:
		var enemies = get_tree().get_nodes_in_group('Enemy')

		if enemies == [actor]:
			EVENTS.emit_signal("room_finished")
