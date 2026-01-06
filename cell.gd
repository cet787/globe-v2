extends MeshInstance3D
class_name Cell

enum ActiveState { ACTIVE, INACTIVE }
enum CellType { WATER, TREES, DIRT }

var active_state: ActiveState = ActiveState.INACTIVE
var cell_type: CellType = CellType.WATER

var active_position: Vector3
var inactive_position: Vector3

var occupied_by: Player

@onready var root: Root = get_tree().current_scene

func _ready() -> void:
	# Set position for when selected
	inactive_position = global_position
	active_position = inactive_position * 1.01
		
	# Set terrain type based of the calculated noise
	var noise_value = root.get_noise_at(global_position)
	if noise_value < 0.0:
		material_override = preload("res://water_material.tres").duplicate()
		cell_type = CellType.WATER
	elif noise_value >= 0.0 and noise_value < 0.35:
		material_override = preload("res://grass_material.tres").duplicate()
		cell_type = CellType.TREES
		inactive_position *= 1.005
		active_position *= 1.005
	elif noise_value >= 0.35:
		material_override = preload("res://dirt_material.tres").duplicate()
		cell_type = CellType.DIRT
		inactive_position *= 1.01
		active_position *= 1.01
	
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
	
func get_materials_allocation():
	return {}
	
	
