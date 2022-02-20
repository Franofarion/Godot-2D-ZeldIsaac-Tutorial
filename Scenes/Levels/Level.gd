extends YSort

onready var pathfinder = $Tilemap/Pathfinder


func _ready() -> void:
	OS.window_fullscreen = true
	OS.window_maximized = true
	
	var enemies = get_tree().get_nodes_in_group('Enemy')
	for enemy in enemies:
		enemy.pathfinder = pathfinder
