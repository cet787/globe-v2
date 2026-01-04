extends MeshInstance3D
class_name Cell

enum ActiveState { ACTIVE, INACTIVE }
var active_state: ActiveState = ActiveState.INACTIVE

var active_position: Vector3
var inactive_position: Vector3

func _ready() -> void:
	material_overlay = material_overlay.duplicate()
	inactive_position = global_position
	active_position = inactive_position * 1.01
	
func _process(_delta) -> void:
	if active_state == ActiveState.ACTIVE:
		global_position = global_position.lerp(active_position, 0.1)
	else:
		global_position = global_position.lerp(inactive_position, 0.1)
	
func highlight():
	material_overlay.set_shader_parameter("highlighted", true)
	active_state = ActiveState.ACTIVE
	
func clear_highlight():
	material_overlay.set_shader_parameter("highlighted", false)
	active_state = ActiveState.INACTIVE
	
	
