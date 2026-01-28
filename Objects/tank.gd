extends InteractiveVehicle
class_name Tank

@onready var message_panel: MessagePanel = get_tree().current_scene.get_node("MessagePanel")

func _ready() -> void:
	_adjust_basis_to_ground()
	$Panel/VBoxContainer/MoveButton.pressed.connect(_on_move_tank_pressed)
	$Panel/VBoxContainer/AttackButton.pressed.connect(_on_attack_pressed)
	
func _process(delta):
	# DebugDraw3D.draw_points(PackedVector3Array([global_position]), DebugDraw3D.POINT_TYPE_SPHERE, 0.05)

	if seek_cell:
		# Get the direction to the target in global space
		var direction_to_target = seek_cell.global_position - global_position
		
		# Transform the direction into the object's local space
		var local_direction = global_transform.basis.inverse() * direction_to_target
		
		# Project onto the XZ plane (removing Y component) to get Y-axis rotation only
		local_direction.y = 0
		
		if local_direction.length_squared() < 0.0001:
			return  # Avoid normalizing zero vector
		local_direction = local_direction.normalized()
		
		# Calculate the angle to rotate around local Y
		var angle = atan2(local_direction.x, -local_direction.z)
		
		# Smoothly interpolate the angle
		var rotation_amount = angle * delta  # Adjust 5.0 for rotation speed
		
		# Rotate the basis around its local Y-axis (which is basis.y)
		global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, rotation_amount)
		
		if abs(angle) < 0.05:
			var nearest_cell: Cell = _get_nearest_cell()
			if nearest_cell.cell_type == Cell.CellType.WATER:
				message_panel.display_message("You cannot drive tank on water.")
				seek_cell = null
				return
			if nearest_cell.occupied_by == null:
				player.occupy_cell(nearest_cell)
			elif nearest_cell.occupied_by != player:
				seek_cell = null
				message_panel.display_message("You must occupy the cell to be able to move it")
				return
			global_position = global_position.move_toward(seek_cell.global_position, 0.01 * delta)
			_adjust_basis_to_ground()

func _get_nearest_cell() -> Cell:
	var cells = get_tree().current_scene.get_cells()
	
	var closest_dist: float = INF
	var closest_cell: Cell
	
	for cell: Cell in cells:
		var dist = cell.global_position.distance_squared_to(global_position)
		if dist < closest_dist:
			closest_cell = cell
			closest_dist = dist
	
	return closest_cell
		
#NOTE This has been removed to avoid errors with user moving computer controlled objects
#WARNING Do not remove code intentionally left for debugging
	
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#match event.keycode:
			#
			#KEY_W:
				#translate(Vector3.FORWARD * 0.01)
			#KEY_S:
				#translate(Vector3.BACK * 0.01)
			#KEY_D:
				#rotate(global_transform.basis.y, PI/16)
			#KEY_A:
				#rotate(global_transform.basis.y, -PI/16)
				#
		#_adjust_basis_to_ground()
				
func _adjust_basis_to_ground():
	if global_position != Vector3.ZERO:
		global_position = global_position.normalized()
		
	var pos = global_position
	if pos.length_squared() < 0.0001:
		return

	# Globe normal
	var up = pos.normalized()

	# Preserve current forward as much as possible
	var forward = -global_transform.basis.z

	# Remove vertical component
	forward -= up * forward.dot(up)

	if forward.length_squared() < 0.0001:
		# Fallback forward if degenerate
		forward = up.cross(Vector3.RIGHT).normalized()

	forward = forward.normalized()
	var right = up.cross(forward).normalized()
	forward = right.cross(up).normalized()

	global_transform.basis = Basis(
		right,
		up,
		-forward
	)

func highlight(timeout: float = INF):
	$Tank.material_overlay.set_shader_parameter("highlight_strength", 1.0)
	if timeout != INF:
		await get_tree().create_timer(timeout).timeout
		$Tank.material_overlay.set_shader_parameter("highlight_strength", 0.0)

func unhighlight():
	$Tank.material_overlay.set_shader_parameter("highlight_strength", 0.0)

func select():
	get_tree().current_scene.get_node("CellPanel").visible = false
	$Tank.material_overlay.set_shader_parameter("selected_highlight_strength", 1.0)
	$Panel/VBoxContainer/Label .text = """Tank
			Ammo: {ammo}
			Attack range: {a_range}
			Move range: {m_range}
			""".format({
				"ammo": ammo,
				"a_range": max_attack_dist,
				"m_range": max_move_dist
			})
	$Panel.visible = true
	$Panel.position = get_viewport().get_mouse_position()

func unselect():
	$Tank.material_overlay.set_shader_parameter("selected_highlight_strength", 0.0)
	$Panel.visible = false

func explode():
	var ap = $AnimationPlayer
	ap.play("SphereAction")
	while ap.is_playing():
		await get_tree().create_timer(0.06).timeout
	queue_free()

func _on_move_tank_pressed():
	var camera: Camera = get_tree().current_scene.get_node("Camera")
	
	if camera.selected_object is Tank:
		var previous_selected_object: Tank = camera.selected_object
		await camera.selected_object_changed
		if camera.selected_object is not Cell:
			print("You must move to an object of type cell")
			message_panel.display_message("You must move to an object of type cell")
			return
		
		if camera.selected_object.global_position.distance_to(previous_selected_object.global_position) > previous_selected_object.max_move_dist:
			print("That cell is farther than the single turn distance limit of 0.125")
			message_panel.display_message("That cell is farther than the single turn distance limit of 0.125")
			return
		
		if camera.selected_object.occupied_by != player and camera.selected_object.occupied_by != null:
			print(camera.selected_object.occupied_by)
			print("You cannot move to a region you don't occupy")
			message_panel.display_message("You cannot move to a region you don't occupy")
			return
		
		previous_selected_object.seek_cell = camera.selected_object
		
func _on_attack_pressed():
	var camera: Camera = get_tree().current_scene.get_node("Camera")
	
	if camera.selected_object is Tank:
		var previous_tank: Tank = camera.selected_object
		await camera.selected_object_changed
		if camera.selected_object is not InteractiveObject:
			print("You can only attack interactive objects")
			message_panel.display_message("You cannot attack that type of object")
			return
		
		if camera.selected_object.global_position.distance_to(previous_tank.global_position) > previous_tank.max_attack_dist:
			print("That tank is farther than the maximum attack distance of 1.0")
			message_panel.display_message("That tank is farther than the maximum attack distance of 1.0")
			
		if previous_tank.ammo < 1:
			print("You must have ammo to attack other tank")
			message_panel.display_message("You must have ammo to attack other tank")
		
		if randf() > previous_tank.accuracy:
			var object_to_delete = camera.selected_object
			camera.selected_object = null
			object_to_delete.explode()
		
		previous_tank.ammo -= 1
		
		#DebugDraw3D.scoped_config().set_thickness(0.001)
		print(previous_tank)
		print(camera.selected_object)
		DebugDraw3D.draw_line(
			previous_tank.global_position, 
			camera.selected_object.global_position,
			Color(1.0, 1.0, 1.0), 1)
