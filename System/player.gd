extends Node
class_name Player

@export var color: Color
@export var player_name: String

var occupied_cells: Array[Cell]
var resources: Dictionary[String, int] = {
	"resource":0
}

enum ResourceErr { OK, OVERDRAFT, INVALID_CATEGORY }

signal cell_just_occupied
signal resources_changed

func _ready():
	await get_tree().process_frame
	resources["resource"] = 150
	_start_resource_panel_updating()

func occupy_cell(cell: Cell):
	occupied_cells.append(cell)
	resources["resource"] -= 1
	cell.occupied_by = self
	_update_resource_panel()
	cell_just_occupied.emit()

func erase_cell(cell: Cell):
	occupied_cells.erase(cell)

## Returns an array of cells that border the players existing cells excluding already occupied cells and water
func get_available_cells():
	
	var available_cells: Array[Cell] = []
	
	# If you have no cells active then all cells are available
	if occupied_cells.size() == 0:
		available_cells = get_tree().current_scene.get_cells()
	
	else:
		for cell in occupied_cells:
			available_cells += cell.neighbors
	
	remove_duplicates(available_cells)
		
	# Remove the cells that are already occupied
	available_cells = available_cells.filter(func(a: Cell) -> bool:
		return true if not a.occupied_by else false)
	
	# Remove the ceel sthat are water type
	available_cells = available_cells.filter(func(a: Cell) -> bool:
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
	resources_changed.emit()

func _update_resource_panel() -> void:
	get_tree().current_scene.get_node("ResourcePanel/VBox/OilResourceLabel").text = "Resources: {resource}".format({
		"resource": resources["resource"]
	})

func remove_duplicates(arr: Array) -> Array:
	var seen := {}
	for element in arr:
		seen[element] = true
	return seen.keys()


func _start_resource_panel_updating():
	_update_resource_panel()
	while true:
		await resources_changed
		_update_resource_panel()

func debt_resources(category: String, qty: int) -> ResourceErr:
	if not category in resources.keys():
		return ResourceErr.INVALID_CATEGORY
	
	if resources[category] > qty:
		resources[category] -= qty
		resources_changed.emit()
		return ResourceErr.OK
	
	else:
		return ResourceErr.OVERDRAFT
		
