extends MeshInstance3D
class_name Cell

enum ActiveState { ACTIVE, INACTIVE }
enum CellType { WATER, TREES, DIRT }

var active_state: ActiveState = ActiveState.INACTIVE
var cell_type: CellType = CellType.WATER
var available_resources: String
var neighbors: Array[Cell]

var active_position: Vector3
var inactive_position: Vector3

@export var resource_allocation_rate: float = 15.0

var occupied_by: Player:
	set(new_player):
		occupied_by = new_player
		material_override.set_shader_parameter("region_highlight_color", occupied_by.color)
		material_override.set_shader_parameter("region_highlight_strength", 0.5)
		allocate_resources(new_player)
		
	get():
		return occupied_by

@onready var root: Root = get_tree().current_scene

func _ready() -> void:
	await get_tree().process_frame
	# Set position for when selected
	inactive_position = global_position
	active_position = inactive_position # * 1.01
		
	# Set terrain type based of the calculated noise
	var noise_value = root.get_noise_at(global_position)
	if noise_value < 0.0:
		material_override = preload("res://water_material.tres").duplicate()
		cell_type = CellType.WATER
		available_resources = "None"
	elif noise_value >= 0.0 and noise_value < 0.35:
		material_override = preload("res://grass_material.tres").duplicate()
		cell_type = CellType.TREES
		#inactive_position *= 1.005
		#active_position *= 1.005
		available_resources = "Wood"
	elif noise_value >= 0.35:
		material_override = preload("res://dirt_material.tres").duplicate()
		cell_type = CellType.DIRT
		#inactive_position *= 1.01
		#active_position *= 1.01
		available_resources = "Oil, Stone"
	
func _process(_delta) -> void:
	if active_state == ActiveState.ACTIVE:
		global_position = global_position.lerp(active_position, 0.1)
	else:
		global_position = global_position.lerp(inactive_position, 0.1)
	
func highlight():
	material_override.set_shader_parameter("highlight_strength", 1.0)
	active_state = ActiveState.ACTIVE
	
func clear_highlight():
	material_override.set_shader_parameter("highlight_strength", 0.0)
	active_state = ActiveState.INACTIVE
	
func allocate_resources(player: Player):
	var player_weakref = weakref(player)
	
	while true:
		await get_tree().create_timer(resource_allocation_rate).timeout
		if player_weakref.get_ref() != occupied_by:
			print("WeakRef does not equal occupied_by")
			break
		if not occupied_by:
			print("Occupied by null")
			break
		occupied_by.collect_resources({
			"resource": 1
		})

func set_neighbors(all_cells: Array[Cell]):
	var best := []

	for cell in all_cells:
		if cell == self:
			continue

		var d := cell.global_position.distance_squared_to(global_position)

		if best.size() < 6:
			best.append([d, cell])
			if best.size() == 6:
				best.sort_custom(func(a, b): return a[0] < b[0])
		elif d < best[5][0]:
			best[5] = [d, cell]
			best.sort_custom(func(a, b): return a[0] < b[0])

	neighbors.clear()
	for entry in best:
		neighbors.append(entry[1])
	
func highlight_cell(timeout: float = 1.0):
	material_overlay.set_shader_parameter("highlight_strength", 1.0)
	await get_tree().create_timer(timeout).timeout
	material_overlay.set_shader_parameter("highlight_strength", 0.0)
	
	
	
