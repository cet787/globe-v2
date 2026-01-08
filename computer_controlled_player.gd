extends Player
class_name ComputerControlledPlayer

func _ready():
	await get_tree().process_frame
	_set_initial_cell()
	resources["resource"] = 1
	
func occupy_cell(cell: Cell):
	if resources["resource"] < 1:
		print("CCP requires one resource to occupy a new cell")
	occupied_cells.append(cell)
	cell.occupied_by = self
	resources["resource"] -= 1
	cell.material_override.set_shader_parameter("region_highlight_color", color)
	cell.material_override.set_shader_parameter("region_highlight_strength", 0.5)
	
func _set_initial_cell():
	var player: Player = get_tree().current_scene.get_node("Player")
	
	await player.cell_just_occupied
	var first_cell = player.occupied_cells[0]
	
	var all_cells = get_tree().current_scene.get_cells()
	var available_cells: Array[Cell]
	
	all_cells.sort_custom(func(a, b) -> bool:
		return first_cell.global_position.distance_squared_to(a.global_position) < first_cell.global_position.distance_squared_to(b.global_position))
	
	available_cells = all_cells.slice(7, 18)
		
	# Remove the cells that are already occupied
	available_cells = available_cells.filter(func(a: Cell) -> bool:
		return true if not a.occupied_by else false)
	
	# Remove the ceel sthat are water type
	available_cells = available_cells.filter(func(a: Cell) -> bool:
		return true if a.cell_type != Cell.CellType.WATER else false)
		
	if available_cells.size() > 0:
		occupy_cell(available_cells.pick_random())
		
	else:
		push_error("NPC could not load first cell")
	
	_start_control_loop()
	
func _start_control_loop():
	
	# Basic control loop that has the game logic
	while true:
		# Make strategy changes when the resources available changes
		await get_tree().create_timer(1.0).timeout
		if resources["resource"] > 0:
			continue
		var available_cells = get_available_cells()
		if available_cells.size() > 0:
			occupy_cell(available_cells.pick_random())
			print(resources["resource"])
