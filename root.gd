extends Node3D


func _ready():
	var children = $globe.get_children()
	
	for child: MeshInstance3D in children:
		if not child.material_overlay:
			continue
			
		child.material_overlay = child.material_overlay.duplicate()
