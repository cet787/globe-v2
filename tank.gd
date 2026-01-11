extends InteractiveVehicle
class_name Tank

var seek_cell: Cell

func _ready() -> void:
	_adjust_basis_to_ground()

	
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
			global_position = global_position.move_toward(seek_cell.global_position, 0.01)
			_adjust_basis_to_ground()
			
		
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.keycode:
			
			KEY_W:
				translate(Vector3.FORWARD * 0.01)
			KEY_S:
				translate(Vector3.BACK * 0.01)
			KEY_D:
				rotate(global_transform.basis.y, PI/16)
			KEY_A:
				rotate(global_transform.basis.y, -PI/16)
				
		_adjust_basis_to_ground()
				
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
	$Tank.material_overlay.set_shader_parameter("selected_highlight_strength", 1.0)

func unselect():
	$Tank.material_overlay.set_shader_parameter("selected_highlight_strength", 0.0)
