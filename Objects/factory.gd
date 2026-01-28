extends InteractiveObject
class_name Factory

var player: Player
		
func _enter_tree() -> void:
	$Panel/DemolishButton.pressed.connect(_on_demolish_pressed)
	allocate_resources()

func highlight(timeout: float = INF):
	$Factory.material_overlay.set_shader_parameter("highlight_strength", 1.0)
	if timeout != INF:
		await get_tree().create_timer(timeout).timeout
		$Factory.material_overlay.set_shader_parameter("highlight_strength", 0.0)

func unhighlight():
	$Factory.material_overlay.set_shader_parameter("highlight_strength", 0.0)

func select():
	$Factory.material_overlay.set_shader_parameter("selected_highlight_strength", 1.0)
	$Panel.visible = true
	var mouse_position = get_viewport().get_mouse_position()
	$Panel.position = mouse_position

func unselect():
	$Factory.material_overlay.set_shader_parameter("selected_highlight_strength", 0.0)
	$Panel.visible = false

func allocate_resources():
	while true:
		await get_tree().create_timer(15.0).timeout
		if not player:
			print("The Factory is not owned by anyone")
			continue
		player.collect_resources({
			"resource": 2
		})

func _on_demolish_pressed():
	pass
