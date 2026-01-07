extends Node
class_name Player

@export var color: Color
@export var player_name: String

var occupied_cells: Array[Cell]
var resources: Dictionary[String, int] = {
	"resource":0
}

signal cell_just_occupied

func _ready():
	resources["resource"] = 1
	_update_resource_panel()

func occupy_cell(cell: Cell):
	occupied_cells.append(cell)
	resources["resource"] -= 1
	_update_resource_panel()
	cell_just_occupied.emit()

## Returns an array of cells that border the players existing cells excluding already occupied cells and water
func get_available_cells():
	var all_cells = get_tree().current_scene.get_cells()
	var available_cells: Array[Cell]
	
	# If you have no cells active then all cells are available
	if occupied_cells.size() == 0:
		available_cells = all_cells.duplicate()
	
	# If you have already placed cells then use only neighboring cellls
	else:
		for cell in occupied_cells:
			
			all_cells.sort_custom(func(a, b) -> bool:
				return cell.global_position.distance_squared_to(a.global_position) < cell.global_position.distance_squared_to(b.global_position))
			var six_closest = all_cells.slice(0, 6)
			for close_cell in six_closest:
				if not available_cells.has(close_cell):
					available_cells.append(close_cell)
		
	# Remove the cells that are already occupied
	available_cells.filter(func(a: Cell) -> bool:
		return true if not a.occupied_by else false)
	
	# Remove the ceel sthat are water type
	available_cells.filter(func(a: Cell) -> bool:
		return true if a.cell_type != Cell.CellType.WATER else false)
	
	if resources["resource"] == 0:
		return []
	
	return available_cells
		
	
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
	_update_resource_panel()

func _update_resource_panel() -> void:
	get_tree().current_scene.get_node("ResourcePanel/VBox/OilResourceLabel").text = "Resources: {resource}".format({
		"resource": resources["resource"]
	})
