@abstract
extends Node3D
class_name InteractiveObject

@abstract
func highlight(timeout: float = INF)

@abstract
func unhighlight()

@abstract
func select()

@abstract
func unselect()

func explode():
	self.queue_free()
