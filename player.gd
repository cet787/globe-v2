extends Node
class_name Player

@export var color: Color
@export var player_name: String

var occupied_cells: Array[Cell]
var resources: Dictionary[String, int] = {
	"dirt": 0,
	"wood": 0,
	"oil": 0,
	"stone": 0,
}

func occupy_cell(cell: Cell):
	occupied_cells.append(cell)
	
func get_available_cells():
	pass
