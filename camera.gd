extends Camera3D

var last_object: Node3D

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
			highlight_object(last_object, false)
			highlight_object(result.collider, true)
			last_object = result.collider
		
		if not last_object:
			highlight_object(result.collider, true)
			last_object = result.collider
	
	#if the mouse is not hovering over a tile
	if not result and last_object:
			highlight_object(last_object, false)
			last_object = null

func highlight_object(collider: Node3D, should_highlight: bool = true):
	var mesh: MeshInstance3D = collider.get_parent()
	var mat: ShaderMaterial = mesh.material_overlay
	mat.set_shader_parameter("highlighted", should_highlight)
	
		
func _process(delta):
	raycast_from_mouse()
	
