extends Node3D
class_name Root

const cell_script = preload("res://cell.gd")
@export var terrain_noise: FastNoiseLite

func _ready():
	pass
	
func get_noise_at(pos: Vector3) -> float:
	return terrain_noise.get_noise_3d(pos.x, pos.y, pos.z)
			
