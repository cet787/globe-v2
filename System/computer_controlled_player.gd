extends Player
class_name ComputerControlledPlayer

func _ready():
	await get_tree().process_frame
	_set_initial_cell()
	resources["resource"] = 150
	
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
		if resources["resource"] < 1:
			continue
		var available_cells = get_available_cells()
		var decision_seed = randf()
		
		# DEBUG
		var factory_placed = occupied_cells.any(func(e: Cell): return true if e.object_on_cell else false)
		if factory_placed:
			continue
	
		if decision_seed < 0.1 and available_cells.size() > 0:
			occupy_cell(available_cells.pick_random())
		
		if decision_seed < 0.3 and decision_seed > 0.1 and resources["resource"] > 2:
			_purchase_factory()
			
			
func _purchase_factory():
	var cells_available = occupied_cells.duplicate()
	
	cells_available = cells_available.filter(func(e: Cell): return false if e.object_on_cell else true)
	
	var where_to_place = cells_available.pick_random()
	
	if !where_to_place:
		print("CCP has no available cells to add factory too")
		return
	
	if resources["resource"] > 2:
		resources["resource"] -= 3
	else:
		print("CCP cannot add factory due to insuffiecient funds")
	
	var new_factory = preload("res://Objects/factory.tscn").instantiate()
	get_tree().root.add_child(new_factory)
	new_factory.global_position = where_to_place.global_position
	var up: Vector3 = new_factory.global_position.normalized()
	var reference = Vector3.FORWARD
	if abs(up.dot(reference)) < 0.99:
		reference = Vector3.RIGHT
	
	var right = reference.cross(up).normalized()
	var forward = up.cross(right).normalized()
	
	new_factory.global_transform.basis = Basis(right, up, -forward)
	new_factory.global_position *= Vector3.ONE * 1.01
	
	new_factory.player = self
	where_to_place.object_on_cell = new_factory
