extends Camera3D

var last_object: Cell
var selected_object: Cell:
	set(new_object):
		if selected_object:
			selected_object.material_override.set_shader_parameter("selected_highlight_strength", 0.0)
		selected_object = new_object
		
		if new_object:
			new_object.material_override.set_shader_parameter("selected_highlight_strength", 1.0)
		
	get():
		return selected_object

var dragging: bool = false
var last_gesture: Vector2
@onready var root: Root = get_tree().current_scene

@onready var camera_anchor: Node3D = get_tree().current_scene.get_node("CameraAnchor")
@onready var camera_marker: Node3D = camera_anchor.get_node("CameraMarker")

@export var mouse_sensitivity: float = 0.1
@export var zoom_sensitivity: float = 0.1

func _ready() -> void:
	get_tree().current_scene.get_node("CellPanel/VBox/OccupyCellButton").pressed.connect(on_occupy_cell_pressed)

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
			if new_object is not Cell:
				return
	
			last_object.clear_highlight()
			new_object.highlight()
			last_object = new_object
		
		if not last_object:
			var new_object = get_object_from_result(result.collider)
			if new_object is not Cell:
				return

			new_object.highlight()
			last_object = new_object
	
	#if the mouse is not hovering over a tile
	if not result and last_object:
			last_object.clear_highlight()
			last_object = null

func _process(_delta):
	global_position = camera_marker.global_position
	look_at(Vector3.ZERO)
	raycast_from_mouse()
	
func _highlight_neighbors():
	var objs = root.get_cells(last_object)
	objs.sort_custom(func(a, b) -> bool: 
		return last_object.global_position.distance_squared_to(a.global_position) < last_object.global_position.distance_squared_to(b.global_position))
	
	var closest_six = objs.slice(0, 6)
	
	for cell in closest_six:
		cell.material_override.set_shader_parameter("region_highlight_strength", 0.8)
		
func _unhandled_input(event: InputEvent) -> void:
	
	# If mouse is pressed occupy cell
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected_object = last_object
			var mouse_pos = get_viewport().get_mouse_position()
			var cell_panel = get_tree().current_scene.get_node("CellPanel")
			var cell_panel_label = cell_panel.get_node("VBox/CellPanelLabel")
			cell_panel_label.text = _get_cell_panel_text()
			if selected_object.occupied_by and selected_object.occupied_by != self:
				cell_panel.get_node("VBox/AttackButton").visible = true
			else:
				cell_panel.get_node("VBox/AttackButton").visible = false
			cell_panel.position = mouse_pos
			cell_panel.visible = true
			
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			selected_object = null
			get_tree().current_scene.get_node("CellPanel").visible = false
			get_tree().current_scene.get_node("CellPanel/VBox/AttackButton").visible = false
		
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			
	if event is InputEventMouseMotion and dragging:
		var delta = event.relative
		camera_anchor.rotation.y -= delta.x * mouse_sensitivity
		camera_anchor.rotation.x -= delta.y * mouse_sensitivity
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
	
func on_occupy_cell_pressed():
	var player: Player = get_tree().current_scene.get_node("Player")
	var available_cells = player.get_available_cells()
	
	if selected_object in available_cells:
		player.occupy_cell(selected_object)
		selected_object.occupied_by = player
		selected_object.material_override.set_shader_parameter("region_highlight_color", player.color)
		selected_object.material_override.set_shader_parameter("region_highlight_strength", 0.5)
		selected_object = null
		get_tree().current_scene.get_node("CellPanel").visible = false
		
	elif selected_object.occupied_by:
		print("Selected object is already occupied by {player}".format({
			"player": selected_object.occupied_by.player_name
		}))
		
	else:
		print("No object to select")
	
	
func _get_cell_panel_text() -> String:
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
