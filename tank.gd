extends Node3D
class_name Tank

var seek_point: Vector3

func _ready() -> void:
	_adjust_basis_to_ground()
	

func _process(delta):
	if seek_point:
		# Get the direction to the target in global space
		var direction_to_target = seek_point - global_position
		
		# Transform the direction into the object's local space
		var local_direction = global_transform.basis.inverse() * direction_to_target
		
		# Project onto the XZ plane (removing Y component) to get Y-axis rotation only
		local_direction.y = 0
		
		if local_direction.length_squared() > 0.001:  # Avoid normalizing zero vector
			local_direction = local_direction.normalized()
			
			# Calculate the angle to rotate around local Y
			var angle = atan2(local_direction.x, local_direction.z)
			
			# Smoothly interpolate the angle
			var rotation_amount = angle * delta  # Adjust 5.0 for rotation speed
			
			# Rotate the basis around its local Y-axis (which is basis.y)
			global_transform.basis = global_transform.basis.rotated(global_transform.basis.y, rotation_amount)
	
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
	var up = global_position.normalized()
	var forward = -global_transform.basis.z
	
	forward = (forward - up * forward.dot(up)).normalized()
	var right = up.cross(forward).normalized()
	forward = right.cross(up).normalized()

	global_transform.basis = Basis(
		right,
		up,
		-forward
	)

	global_position = up
	global_transform.basis.z.rotated(
		global_transform.basis.z,
		PI
	)
