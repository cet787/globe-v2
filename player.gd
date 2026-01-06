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
	
func collect_resources(resource_dict: Dictionary[String, int]) -> void:
	for key in resource_dict.keys():
		if not key in resources.keys():
			push_warning(
				"{resource_key} not found in player({player_name}) resource dictionary".format({
					"resource_key":key,
					"player_name": player_name
			}))
			continue
		resources[key] += resource_dict[key]
		print(resources)
	get_tree().current_scene.get_node("Panel/VBox/OilResourceLabel").text = "Oil: {oil_num}".format({
		"oil_num": resources["oil"]
	})
