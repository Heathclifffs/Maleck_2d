extends Node

signal health_changed(current_hp, max_hp)

@export var max_hp := 10
var current_hp: int

func _ready():
    current_hp = max_hp

func take_damage(amount: int):
    current_hp = max(0, current_hp - amount)
    health_changed.emit(current_hp, max_hp)

func heal(amount: int):
    current_hp = min(max_hp, current_hp + amount)
    health_changed.emit(current_hp, max_hp)
