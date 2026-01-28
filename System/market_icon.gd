extends SubViewport

@export var node_path: String
var focus_object: Node

func _ready():
	var new_node = load(node_path)
	
	if not new_node:
		push_error("Cannot parse the icon object at location: %s" % node_path)
	
	new_node = new_node.instantiate()
	focus_object = new_node
	add_child(new_node)
	
	$Camera.look_at(Vector3.ZERO)
	
func _process(delta: float) -> void:
	if not focus_object:
		return
	
	focus_object.rotation.y += PI/4 * delta
	
