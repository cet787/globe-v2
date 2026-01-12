@abstract
extends Node3D
class_name InteractiveVehicle

var player: Player
var seek_cell: Cell
var ammo: int = 8
var max_attack_dist: float = 1.0
var max_move_dist: float = 0.125
var accuracy: float = 0.5

@abstract
func highlight(timeout: float = INF)

@abstract
func unhighlight()

@abstract
func select()

@abstract
func unselect()
