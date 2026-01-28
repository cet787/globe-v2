extends Camera3D
class_name Camera

var last_object
var selected_object:
	set(new_object):
		if selected_object:
			selected_object.unselect()
		selected_object = new_object
		
		if new_object:
			new_object.select()
			selected_object_changed.emit()
		
	get():
		return selected_object
		
signal selected_object_changed

var dragging: bool = false
var last_gesture: Vector2
@onready var root: Root = get_tree().current_scene
@onready var message_panel: MessagePanel = get_tree().current_scene.get_node("MessagePanel")

@onready var camera_anchor: Node3D = get_tree().current_scene.get_node("CameraAnchor")
@onready var camera_marker: Node3D = camera_anchor.get_node("CameraMarker")

@export var mouse_sensitivity: float = 0.05
@export var zoom_sensitivity: float = 2.0

@onready var market: Market = get_tree().current_scene.get_node("Market")

var first_cell_selected: bool = false

func _ready() -> void:
	fov = 35.0
	#get_tree().current_scene.get_node("CellPanel/VBox/OccupyCellButton").pressed.connect(on_occupy_cell_pressed)
	#get_tree().current_scene.get_node("CellPanel/VBox/AttackButton").pressed.connect(_on_attack_button_presssed)
	#get_tree().current_scene.get_node("CellPanel/VBox/AddTankButton").pressed.connect(_on_add_tank_pressed)
	#get_tree().current_scene.get_node("CellPanel/VBox/MoveTankButton").pressed.connect(_on_move_tank_pressed)
	#get_tree().current_scene.get_node("CellPanel/VBox/AttackTankButton").pressed.connect(_on_attack_tank_pressed)
	get_tree().current_scene.get_node("Market").pending_purchase.connect(_on_pending_purchase)
	get_tree().current_scene.get_node("CellPanel/VBox/OccupyFirstCellButton").pressed.connect(_on_occupy_cell_pressed)
	get_tree().current_scene.get_node("CellPanel/VBox/OccupyCellButton").pressed.connect(_on_occupy_cell_pressed)
	get_tree().current_scene.get_node("CellPanel/VBox/MarketButton").pressed.connect(_on_market_button_pressed)
	get_tree().current_scene.get_node("ResourcePanel/VBox/HighlightNeighbors").pressed.connect(_on_highlight_neighbors_pressed)
	get_tree().current_scene.get_node("CellPanel/VBox/DrawLineButton").pressed.connect(_on_draw_line_pressed)
	
func raycast_from_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = self.project_ray_origin(mouse_pos)
	var direction = project_ray_normal(mouse_pos)
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 1000.0
	)
	
	var result = space.intersect_ray(query)
	# If the mouse is hovering over a tile
	if result:
		if last_object and result.collider == last_object:
			return
			
		if last_object and result.collider != last_object:
			var new_object = get_object_from_result(result.collider)
			if new_object is not Cell and new_object is not InteractiveObject:
				return
	
			last_object.unhighlight()
			new_object.highlight()
			last_object = new_object
		
		if not last_object:
			var new_object = get_object_from_result(result.collider)
			if new_object is not Cell and new_object is not InteractiveObject:
				return

			new_object.highlight()
			last_object = new_object
	
	#if the mouse is not hovering over a tile
	if not result and last_object:
		last_object.unhighlight()
		last_object = null

func _process(_delta):
	global_position = camera_marker.global_position
	look_at(Vector3.ZERO)
	raycast_from_mouse()

#TODO This will be depricated confirm one run prior to completely removing
#func _highlight_neighbors():
	#var objs = root.get_cells(last_object)
	#objs.sort_custom(func(a, b) -> bool: 
		#return last_object.global_position.distance_squared_to(a.global_position) < last_object.global_position.distance_squared_to(b.global_position))
	#
	#var closest_six = objs.slice(0, 6)
	#
	#for cell in closest_six:
		#cell.material_override.set_shader_parameter("region_highlight_strength", 0.8)
		
func _unhandled_input(event: InputEvent) -> void:
	
	# If mouse is pressed occupy cell
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected_object = last_object
			if not selected_object:
				return
			var mouse_pos = get_viewport().get_mouse_position()
			var cell_panel = get_tree().current_scene.get_node("CellPanel")
			var cell_panel_label = cell_panel.get_node("VBox/CellPanelLabel")
			cell_panel_label.text = _get_panel_text()
			
			var player:Player =get_tree().current_scene.get_node("Player")
			if player.occupied_cells.size() == 0 and not first_cell_selected:
				cell_panel.get_node("VBox/OccupyFirstCellButton").visible = true
				cell_panel.get_node("VBox/OccupyCellButton").visible = false
				cell_panel.get_node("VBox/MarketButton").visible = false
			else:
				cell_panel.get_node("VBox/OccupyFirstCellButton").visible = false
				
				
			
			if selected_object is Cell and first_cell_selected:
				cell_panel.get_node("VBox/OccupyCellButton").visible = true
				cell_panel.get_node("VBox/MarketButton").visible = true
			
			if selected_object is Cell:
				cell_panel.position = mouse_pos
				cell_panel.visible = true
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_object = null
			get_tree().current_scene.get_node("CellPanel").visible = false
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			fov -= 0.1 * zoom_sensitivity
		
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			fov += 0.1 * zoom_sensitivity
		
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			
	if event is InputEventMouseMotion and dragging:
		var delta = event.relative
		camera_anchor.rotation.y -= delta.x * mouse_sensitivity * (fov / 35)
		camera_anchor.rotation.x -= delta.y * mouse_sensitivity * (fov / 35)
		camera_anchor.rotation.x = clamp(
			camera_anchor.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
		
	if event is InputEventMagnifyGesture:
		fov -= (event.factor - 1) * zoom_sensitivity
		
	if event is InputEventPanGesture:
		camera_anchor.rotation.y += event.delta.x * mouse_sensitivity
		camera_anchor.rotation.x += event.delta.y * mouse_sensitivity
	
		
func get_object_from_result(collider):
	return collider.get_parent()
	
func _on_occupy_cell_pressed():
	var player: Player = get_tree().current_scene.get_node("Player")
	var available_cells = player.get_available_cells()
	
	if selected_object in available_cells:
		player.occupy_cell(selected_object)
		if not first_cell_selected:
			first_cell_selected = true
		selected_object = null
		get_tree().current_scene.get_node("CellPanel").visible = false
		
	elif selected_object.occupied_by:
		print("Selected object is already occupied by {player}".format({
			"player": selected_object.occupied_by.player_name
		}))
		message_panel.display_message("Selected object is already occupied by {player}".format({
			"player": selected_object.occupied_by.player_name
		}))
		
	else:
		print("No object to select")
		message_panel.display_message("No object to select")
	
	
func _get_panel_text() -> String:
	if not selected_object:
		return ""
	
	if selected_object is Cell:
		if not selected_object.occupied_by:
			return """{title}
			Type: {type}
			Resources: {resource_list}
			""".format({
				"title": "Undiscovered" if not selected_object.occupied_by else "Discovered",
				"type": Cell.CellType.keys()[selected_object.cell_type].to_lower().capitalize(),
				"resource_list": selected_object.available_resources
			})
		
		elif selected_object.occupied_by and selected_object.occupied_by == self:
			return """Occupied by you
			Type: {type}
			Resources: {resource_list}
			""".format({
				"type": Cell.CellType.keys()[selected_object.cell_type].to_lower().capitalize(),
				"resource_list": selected_object.available_resource
			})
		
		elif selected_object.occupied_by and selected_object.occupied_by != self:
			return """Occupied by {opponent}
			Type: {type}
			Resources: {resource_list}
			""".format({
				"opponent": selected_object.occupied_by.player_name,
				"type": Cell.CellType.keys()[selected_object.cell_type].to_lower().capitalize(),
				"resource_list": selected_object.available_resources
			})
		else:
			return "Cell state unknown"
	
	elif selected_object is InteractiveVehicle:
		if selected_object is Tank:
			return """Tank
			Ammo: {ammo}
			Attack range: {a_range}
			Move range: {m_range}
			""".format({
				"ammo": selected_object.ammo,
				"a_range": selected_object.max_attack_dist,
				"m_range": selected_object.max_move_dist
			})
		else:
			return "Unkown/incompatible type"
	
	else:
		return "Unkown/incompatible type"

#TODO should be depricated onw at least once before completely removing	
func _on_highlight_neighbors_pressed():
	if selected_object:
		for neighbor in selected_object.neighbors:
			neighbor.highlight_cell()
	
	else:
		print("An object must be selected to highlight neighbor")
	
func _on_market_button_pressed():
	market.open()
	get_tree().current_scene.get_node("CellPanel").visible = false

func _on_attack_button_presssed():
	var attacker: Player = get_tree().current_scene.get_node("Player")
	var defender: Player = selected_object.occupied_by
	
	# Calculate the odds that each will win
	if attacker.resources["resource"] < 1:
		message_panel.display_message("You must have at least 1 resource to attack opponent.")
		print("You must have at least 1 resource to attack opponent.")
		return
	
	var total_resources = attacker.resources["resource"] + defender.resources["resource"]
	var attacker_coefficient = attacker.resources["resource"] / total_resources
	
	if randf() < attacker_coefficient:
		var is_border: bool = false
		for cell: Cell in selected_object.neighbors:
			if cell.occupied_by == attacker:
				is_border = true
				
		if not is_border:
			message_panel.display_message("You must border your oponents region to attack.")
			print("You must border your oponents region to attack.")
			return
		
		defender.erase_cell(selected_object)
		attacker.occupy_cell(selected_object)
		selected_object.occupied_by = attacker
		message_panel.display_message("You won the battle")
		print("You won the battle")
	else:
		message_panel.display_message("You lost the battle")
		print("You lost the battle")
		

#func _on_add_tank_pressed():
	#var player: Player = get_tree().current_scene.get_node("Player")
	#if player.occupied_cells.size() > 0 and selected_object is Cell and selected_object.occupied_by != player:
		#message_panel.display_message("You must place a tank on a cell that you occupy")
		#return
	#
	#elif player.occupied_cells.size() == 0 and selected_object is Cell and not selected_object.occupied_by:
		#player.occupy_cell(selected_object)
		#
	#elif selected_object is not Cell:
		#message_panel.display_message("An error occured... You cannot place tank on a object of non-Cell type.")
		#return
		#
	#elif selected_object.occupied_by != player:
		#message_panel.display_message("You cannot place a tank on another players cell.")
		#return
		#
	#
	#var new_tank = preload("res://tank.tscn").instantiate()
	#get_tree().current_scene.add_child(new_tank)
	#new_tank.add_to_group("tanks")
	#new_tank.global_position = selected_object.global_position
	#new_tank._adjust_basis_to_ground()
	#new_tank.player = get_tree().current_scene.get_node("Player")
	
func _on_pending_purchase(object_data: Dictionary):
	match object_data["name"]:
		"Factory":
			_purchase_factory(object_data)
		"BattleShip":
			_purchase_battle_ship(object_data)
		"Tank":
			_purchase_tank(object_data)
		_:
			push_error("Unrecoginzed type from market %s" % object_data["name"])
			
			
	
#func _on_move_tank_pressed():
	#if selected_object is Tank:
		#var previous_selected_object: Tank = selected_object
		#await selected_object_changed
		#if selected_object is not Cell:
			#print("You must move to an object of type cell")
			#message_panel.display_message("You must move to an object of type cell")
			#return
		#
		#if selected_object.global_position.distance_to(previous_selected_object.global_position) > previous_selected_object.max_move_dist:
			#print("That cell is farther than the single turn distance limit of 0.125")
			#message_panel.display_message("That cell is farther than the single turn distance limit of 0.125")
			#return
		#
		#previous_selected_object.seek_cell = selected_object
		#
		
#func _on_attack_tank_pressed():
	#if selected_object is Tank:
		#var previous_tank: Tank = selected_object
		#await selected_object_changed
		#if selected_object is not Tank:
			#print("You must attack an object of type tank")
			#message_panel.display_message("You must attack an object of type tank")
			#return
		#
		#if selected_object.global_position.distance_to(previous_tank.global_position) > previous_tank.max_attack_dist:
			#print("That tank is farther than the maximum attack distance of 1.0")
			#message_panel.display_message("That tank is farther than the maximum attack distance of 1.0")
			#
		#if previous_tank.ammo < 1:
			#print("You must have ammo to attack other tank")
			#message_panel.display_message("You must have ammo to attack other tank")
			#
		#if randf() > previous_tank.accuracy:
			#var object_to_delete = selected_object
			#selected_object = null
			#object_to_delete.explode()
		#
		#previous_tank.ammo -= 1
		
func _purchase_factory(object_data: Dictionary):
	var player: Player = get_tree().current_scene.get_node("Player")
	
	if selected_object is Cell and not selected_object in player.occupied_cells:
		message_panel.display_message("You must occupy the region you're placing a factory on.")
		return
	
	elif selected_object is not Cell:
		message_panel.display_message("You must select a region before you can place a factory on it.")
		return
		
	if selected_object.object_on_cell:
		message_panel.display_message("The region must be empty for you to place a factory")
	
	var resource_err = player.debt_resources("resource", object_data["cost"])
	
	if resource_err == Player.ResourceErr.OVERDRAFT:
		message_panel.display_message("You do not have enough resources to purchase factory.")
		return
	
	elif resource_err == Player.ResourceErr.INVALID_CATEGORY:
		push_error("Invalid category when trying to purchase tank")
		return
	
	var new_factory = preload("res://Objects/factory.tscn").instantiate()
	get_tree().root.add_child(new_factory)
	new_factory.global_position = selected_object.global_position
	var up: Vector3 = new_factory.global_position.normalized()
	var reference = Vector3.FORWARD
	if abs(up.dot(reference)) < 0.99:
		reference = Vector3.RIGHT
	
	var right = reference.cross(up).normalized()
	var forward = up.cross(right).normalized()
	
	new_factory.global_transform.basis = Basis(right, up, -forward)
	new_factory.global_position *= Vector3.ONE * 1.01
	
	new_factory.player = player
	selected_object.object_on_cell = new_factory
		
func _purchase_tank(object_data: Dictionary):
	var player: Player = get_tree().current_scene.get_node("Player")
	if player.occupied_cells.size() > 0 and selected_object is Cell and selected_object.occupied_by != player:
		message_panel.display_message("You must place a tank on a cell that you occupy")
		return
	
	elif player.occupied_cells.size() == 0 and selected_object is Cell and not selected_object.occupied_by:
		player.occupy_cell(selected_object)
		
	elif selected_object is not Cell:
		message_panel.display_message("An error occured... You cannot place tank on a object of non-Cell type.")
		return
		
	elif selected_object.occupied_by != player:
		message_panel.display_message("You cannot place a tank on another players cell.")
		return
	
	# Check if there are enough resources to buy the tank
	var resource_err = player.debt_resources("resource", object_data["cost"])
	
	if resource_err == Player.ResourceErr.OVERDRAFT:
		message_panel.display_message("You do not have enough resources to purchase tank.")
		return
		
	elif resource_err == Player.ResourceErr.INVALID_CATEGORY:
		push_error("Invalid category when trying to purchase tank")
		return
	
	var new_tank = preload("res://Objects/tank.tscn").instantiate()
	get_tree().current_scene.add_child(new_tank)
	new_tank.add_to_group("tanks")
	new_tank.global_position = selected_object.global_position
	new_tank._adjust_basis_to_ground()
	new_tank.player = get_tree().current_scene.get_node("Player")
	
	player.resources["resource"] -= int(object_data["cost"])
	
func _purchase_battle_ship(object_data: Dictionary):
	var player: Player = get_tree().current_scene.get_node("Player")
	
	if selected_object is not Cell:
		message_panel.display_message("You must place battle ship on a water region.")
		return
		
	if selected_object is Cell and selected_object.cell_type != Cell.CellType.WATER:
		message_panel.display_message("You must place battle ship on a water region.")
		return
	
	var resource_err = player.debt_resources("resource", object_data["cost"])
	
	if resource_err == Player.ResourceErr.INVALID_CATEGORY:
		push_error("Invalid category when trying to purchase battle ship")
		return
	
	elif resource_err == Player.ResourceErr.OVERDRAFT:
		message_panel.display_message("You do not have sufficient funds to purchase battle ship.")
		return
	
	
	var new_ship = preload("res://Objects/battle_ship.tscn").instantiate()
	get_tree().current_scene.add_child(new_ship)
	new_ship.add_to_group("tanks")
	new_ship.global_position = selected_object.global_position
	new_ship._adjust_basis_to_ground()
	new_ship.player = get_tree().current_scene.get_node("Player")
	
	player.resources["resource"] -= int(object_data["cost"])
	
func _on_draw_line_pressed():
	var first_cell = selected_object
	await selected_object_changed
	var second_cell = selected_object
	
	if not first_cell is Cell and not second_cell is Cell:
		message_panel.display_message("You can only draw a line between two cell types")
		print("You can only draw a line between two cell types")
		return
	
	var direction: Vector3 = (second_cell.global_position - first_cell.global_position).normalized()
	var distance: float = first_cell.global_position.distance_to(second_cell.global_position)
	direction *= distance
	var step_size: float = 0.05
	var line_points: Array[Vector3] = []
	var current_step: float = 0.0
	
	# Draw direct line between the cells
	while current_step <= 1.0:
		line_points.append(first_cell.global_position + direction * current_step)
		current_step += step_size
	
	# Add one last point to take the line to the final point.
	line_points.append(first_cell.global_position + direction * current_step)
	
	# Correct the positions so that it is on the surface of the planet
	for i in range(line_points.size()):
		line_points[i] = line_points[i].normalized() * 1.02
	
	var line_segments: Array[Vector3] = []
	for i in range(1, line_points.size()):
		line_segments.append(line_points[i - 1])
		line_segments.append(line_points[i])
	
	
	DebugDraw3D.scoped_config().set_thickness(0.01)
	DebugDraw3D.draw_lines(PackedVector3Array(line_segments), Color(1.0, 0.0, 0.0), 60.0)
	
	print(line_points.size())
	
