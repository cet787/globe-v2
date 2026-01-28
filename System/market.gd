extends Control
class_name Market

var selected_object_name: String
var object_data: Dictionary

signal pending_purchase

func _ready() -> void:
	for button: Button in $Panel/VBoxContainer/ScrollContainer/HBoxContainer.get_children():
		var object_name = button.name.replace("Button", "")
		button.pressed.connect(_on_object_pressed.bind(object_name))
	
	$Panel/VBoxContainer/ButtonsContainer/BuyButton.pressed.connect(_on_buy_pressed)
	$Panel/VBoxContainer/ButtonsContainer/ClearButton.pressed.connect(_on_clear_pressed)
	$Panel/VBoxContainer/CloseButton.pressed.connect(close)
	
	object_data = _load_object_data()
	
func _on_object_pressed(object_name: String):
	selected_object_name = object_name
	
	$Panel/VBoxContainer/SelectedObject/TextureRect.texture = get_node("%sIcon" % selected_object_name).get_texture()
	$Panel/VBoxContainer/SelectedObject/DescriptionContainer/TypeLabel.text = "Type: %s" % object_data[selected_object_name]["type"].capitalize()
	$Panel/VBoxContainer/SelectedObject/DescriptionContainer/CostLabel.text = "Cost: %d" % object_data[selected_object_name]["cost"]
	$Panel/VBoxContainer/SelectedObject/DescriptionContainer/DescriptionLabel.text = object_data[selected_object_name]["description"]
	
	#match object_name:
		#"Factory":
			#$Panel/VBoxContainer/SelectedObject/TextureRect.texture = $FactoryIcon.get_texture()
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/TypeLabel.text = "Type: %s" % object_data["Factory"]
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/CostLabel.text = "Cost: 50"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/DescriptionLabel.text = "Production Rate: 2"
			#
		#"Tank":
			#$Panel/VBoxContainer/SelectedObject/TextureRect.texture = $TankIcon.get_texture()
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/TypeLabel.text = "Type: Tank"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/CostLabel.text = "Cost: 25"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/DescriptionLabel.text = """Ammo Quantity: 8
			#Range: 0.125"""
		#
		#"BattleShip":
			#$Panel/VBoxContainer/SelectedObject/TextureRect.texture = $BattleShipIcon.get_texture()
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/TypeLabel.text = "Type: Ship"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/CostLabel.text = "Cost: 75"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/DescriptionLabel.text = """Ammo Quantity: 8
			#Range: 0.125"""
		#
		#_:
			#$Panel/VBoxContainer/SelectedObject/TextureRect.texture = null
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/TypeLabel.text = "Error"
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/CostLabel.text = ""
			#$Panel/VBoxContainer/SelectedObject/DescriptionContainer/DescriptionLabel.text = ""
			
	$Panel/VBoxContainer/SelectedObject.visible = true
	$Panel/VBoxContainer/ButtonsContainer.visible = true
	
func _on_buy_pressed():
	var player:Player = get_tree().current_scene.get_node("Player")
	pending_purchase.emit(object_data[selected_object_name])
	
func _on_clear_pressed():
	$Panel/VBoxContainer/SelectedObject.visible = false
	$Panel/VBoxContainer/ButtonsContainer.visible = false

func _load_object_data():
	if not FileAccess.file_exists("res://System/object_data.json"):
		push_error("object_data.json not found check location of this file")
	
	var json_as_text = FileAccess.get_file_as_string("res://System/object_data.json")
	return JSON.parse_string(json_as_text)
	
func open():
	visible = true
	
func close():
	visible = false
