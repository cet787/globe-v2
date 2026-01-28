@abstract
extends InteractiveObject
class_name InteractiveVehicle

var seek_cell: Cell
var ammo: int = 8
var max_attack_dist: float = 1.0
var max_move_dist: float = 0.125
var accuracy: float = 0.5
var player: Player
