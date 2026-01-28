extends Node3D

var resources: int = 0
var current_node: Node

#TEST this script is designed to be removed before release
func _ready():
	var node1 = Node.new()
	node1.name = "node_1"
	var node2 = Node.new()
	node2.name = "node_2"
		
	current_node = node1
	print("Allocating Resources")
	allocate_resources()
	await get_tree().create_timer(10.0).timeout
	current_node = node2
	
func allocate_resources():
	while true:
		await get_tree().create_timer(1.0).timeout
		resources += 1
		print("Resources %d, Current Node: %s, Start Node: %s" % [resources, current_node.name, start_node.name])
