extends Panel
class_name MessagePanel

func display_message(message: String, timeout: float = 5.0):
	$MessageLabel.text = message
	$MessageLabel.visible = true
	
	await get_tree().create_timer(timeout).timeout
	
	$MessageLabel.text = ""
	$MessageLabel.visible = false
