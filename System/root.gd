extends Node3D
class_name Root

const cell_script = preload("res://System/cell.gd")
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
		
	#NOTE Measure neighbor distance statistics
	#var min_dist := INF
	#var max_dist := 0.0
	#var sum_dist := 0.0
	#var count := 0
#
	#for child: Cell in $globe.get_children():
		#for neighbor: Cell in child.neighbors:
			#var d := child.global_position.distance_to(neighbor.global_position)
			#min_dist = min(min_dist, d)
			#max_dist = max(max_dist, d)
			#sum_dist += d
			#count += 1
#
	#if count > 0:
		#var avg_dist := sum_dist / count
		#print("Cell neighbor distances")
		#print("Max: %f, Min: %f, Avg: %f" % [max_dist, min_dist, avg_dist])
	#else:
		#print("No neighbor distances found")
		

func get_cells(exclude: Cell = null) -> Array[Cell]:
	if not exclude:
		return cells.duplicate()
	
	return cells.filter(func(cell): return cell != exclude)
	
		
func get_noise_at(pos: Vector3) -> float:
	return terrain_noise.get_noise_3d(pos.x, pos.y, pos.z)

func _process(delta: float) -> void:
	# Control Day Night cycle
	$Light.rotation.y -= 2 * PI * delta / 120
	pass
	
			
