@tool
extends EditorScript

const cell_script = preload("res://cell.gd")
func _run() ->  void:
	var globe: Node3D = get_scene()
	
	# If the mesh is a globe_cell set the cell.gd
	for mesh: MeshInstance3D in globe.get_children():
		if mesh.name.substr(0, 10) != "globe_cell":
			continue
		mesh.set_script(cell_script)
		
