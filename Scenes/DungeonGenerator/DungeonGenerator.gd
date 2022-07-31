extends Node2D
class_name DungeonGenerator

const MIN_DUNGEON_DEPTH = 7

enum CELL_TYPE {
	EMPTY, # = 0
	WALL # = 1
}

onready var tilemap = $TileMap
onready var cell_distances = $CellDistances

export var grid_size := Vector2(10, 10)

var grid : Array = []

var walker_array = []
var dijkstra_map = []


var entry_cell : Vector2
var exit_cell : Vector2


class CellDistance:
	var cell := Vector2.INF
	var dist : int = -1

	func _init(_cell: Vector2, _dist: int) -> void:
		cell = _cell
		dist = _dist



#### ACCESSORS ####

func is_class(value: String): return value == "DungeonGenerator" or .is_class(value)
func get_class() -> String: return "DungeonGenerator"


#### BUILT-IN ####
func _ready() -> void:
	_init_grid()
	_update_grid_display()

### VIRTUALS ###




#### LOGIC ####
func _generate_dungeon() -> void:
	print("Generation started")
	_init_grid()
	dijkstra_map = []

	while(get_dungeon_depth() < MIN_DUNGEON_DEPTH):
		_init_grid()
		entry_cell = _get_random_cell()
		_place_walker(entry_cell)
		dijkstra_map = []

		while(!walker_array.empty()):
			for walker in walker_array:
				var accessible_cells = _get_accessible_cells(walker.cell)
				walker.step(accessible_cells)

		_update_grid_display()
		compute_cell_distances(entry_cell)

	var furtherest_cells = get_furtherest_cells()
	exit_cell = furtherest_cells[randi() % furtherest_cells.size()]

	_place_entry_and_exit_cells()
	_display_dijkstra_map()

	print("Generation finished")


func _set_cell(cell: Vector2, cell_type: int) -> void:
	grid[cell.x][cell.y] = cell_type


func _init_grid() -> void:
	grid = []

	for i in range(grid_size.x):
		grid.append([])

		for _j in range(grid_size.y):
			grid[i].append(CELL_TYPE.WALL)


func _update_grid_display() -> void:
	for i in range(grid_size.x):
		for j in range(grid_size.y):
			var cell_type = grid[i][j]

			tilemap.set_cell(i, j, cell_type - 1)


func _place_walker(cell: Vector2, max_nb_steps: int = 9, nb_sub_walker: int = 2) -> void:
	var walker = Walker.new(cell, max_nb_steps, nb_sub_walker)
	walker_array.append(walker)
	add_child(walker)

	var __ = walker.connect("moved", self, "_on_walker_moved")
	__ = walker.connect("arrived", self, "_on_walker_arrived", [walker])
	__ = walker.connect("sub_walker_creation", self, "_on_walker_sub_walker_creation")


func _get_random_cell() -> Vector2:
	return  Vector2(
		randi() % int(grid_size.x),
		randi() % int(grid_size.y)
	)


func _get_accessible_cells(cell: Vector2) -> Array:
	var adjacents = Utils.get_adjacents_cells(cell)
	var accessibles = []

	for adj in adjacents:
		if is_inside_grid(adj) && grid[adj.x][adj.y] == CELL_TYPE.WALL:
			accessibles.append(adj)

	return accessibles


func is_inside_grid(cell: Vector2) -> bool:
	return cell.x >= 0 && cell.x < grid_size.x && \
					cell.y >= 0 && cell.y < grid_size.y


func compute_cell_distances(cell: Vector2, distance : int = 0) -> void:
	if dijkstra_map.empty():
		dijkstra_map.append(CellDistance.new(cell, distance))

	distance += 1

	var adjacents = Utils.get_adjacents_cells(cell)

	for adj in adjacents:
		var tile_id = tilemap.get_cell(adj.x, adj.y)

		if tile_id != -1 or !is_inside_grid(adj):
			continue

		var cell_dist = get_dijkstra_cell_dist(adj)

		if cell_dist == null:
			dijkstra_map.append(CellDistance.new(adj, distance))
			compute_cell_distances(adj, distance)

		elif cell_dist.dist > distance:
			cell_dist.dist = distance
			compute_cell_distances(adj, distance)


func get_dijkstra_cell_dist(cell: Vector2) -> CellDistance:
	for cell_dist in dijkstra_map:
		if cell_dist.cell.is_equal_approx(cell):
			return cell_dist
	return null


func _display_dijkstra_map() -> void:
	for child in cell_distances.get_children():
		child.queue_free()

	var cell_size = tilemap.get_cell_size()

	for cell_dist in dijkstra_map:
		var label = Label.new()
		label.text = String(cell_dist.dist)

		label.set_position(cell_dist.cell * cell_size * tilemap.scale)
		cell_distances.add_child(label)


func _place_entry_and_exit_cells() -> void:
	var entry_id = tilemap.tile_set.find_tile_by_name("Entry")
	tilemap.set_cellv(entry_cell, entry_id)

	var exit_id = tilemap.tile_set.find_tile_by_name("Exit")
	tilemap.set_cellv(exit_cell, exit_id)


func get_furtherest_cells() -> PoolVector2Array:
	var dungeon_depth = get_dungeon_depth()

	var furtherest_cells = PoolVector2Array()

	for cell_dist in dijkstra_map:
		if cell_dist.dist == dungeon_depth:
			furtherest_cells.append(cell_dist.cell)

	return furtherest_cells


func get_dungeon_depth() -> int:
	var max_depth = 0
	for cell_dist in dijkstra_map:
		if cell_dist.dist > max_depth:
			max_depth = cell_dist.dist
	return max_depth


### INPUTS ###

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_generate_dungeon()


#### SIGNAL RESPONSES ####

func _on_walker_moved(cell: Vector2) -> void:
	_set_cell(cell, CELL_TYPE.EMPTY)


func _on_walker_arrived(walker: Walker) -> void:
	walker_array.erase(walker)
	walker.queue_free()

func _on_walker_sub_walker_creation(cell: Vector2, max_nb_steps: int, nb_sub_walker: int) -> void:
	_place_walker(cell, max_nb_steps, nb_sub_walker)
