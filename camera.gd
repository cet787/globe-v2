extends Camera3D

var last_object: Cell

func raycast_from_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var origin = self.project_ray_origin(mouse_pos)
	var direction = project_local_ray_normal(mouse_pos)
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		origin,
		origin + direction * 1000.0
	)
	
	var result = space.intersect_ray(query)
	# If the mouse is hovering over a tile
	if result:
		if last_object and result.collider == last_object:
			return
			
		if last_object and result.collider != last_object:
			var new_object = get_object_from_result(result.collider)
			if new_object is not Cell:
				return
	
			last_object.clear_highlight()
			new_object.highlight()
			last_object = new_object
		
		if not last_object:
			var new_object = get_object_from_result(result.collider)
			if new_object is not Cell:
				return

			new_object.highlight()
			last_object = new_object
	
	#if the mouse is not hovering over a tile
	if not result and last_object:
			last_object.clear_highlight()
			last_object = null

func get_object_from_result(collider):
	return collider.get_parent()
		
func _process(_delta):
	raycast_from_mouse()
	
