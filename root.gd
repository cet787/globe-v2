extends Node3D
class_name Root

const cell_script = preload("res://cell.gd")
@export var terrain_noise: FastNoiseLite
var cells: Array[Cell]

func _ready():
	await get_tree().process_frame
	var children = $globe.get_children()
	for child in children:
		if child is Cell:
			cells.append(child)
			
	for child in children:
		child.set_neighbors(get_cells(child))
			
func get_cells(exclude: Cell = null) -> Array[Cell]:
	if not exclude:
		return cells.duplicate()
	
	return cells.filter(func(cell): return cell != exclude)
	
		
func get_noise_at(pos: Vector3) -> float:
	return terrain_noise.get_noise_3d(pos.x, pos.y, pos.z)
			
