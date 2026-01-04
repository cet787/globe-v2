extends MeshInstance3D
class_name Cell

enum ActiveState { ACTIVE, INACTIVE }
var active_state: ActiveState = ActiveState.INACTIVE

var active_position: Vector3
var inactive_position: Vector3

@onready var root: Root = get_tree().current_scene

func _ready() -> void:
	# Set position for when selected
	inactive_position = global_position
	active_position = inactive_position * 1.01
		
	# Set terrain type based of the calculated noise
	if root.get_noise_at(global_position) < 0.0:
		material_override = preload("res://water_material.tres").duplicate()
	else:
		material_override = preload("res://grass_material.tres").duplicate()
	
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
	
	
