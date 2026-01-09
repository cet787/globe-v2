extends Node3D
class_name Tank

func _ready() -> void:
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
