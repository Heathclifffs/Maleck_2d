extends Node

signal stamina_changed(current, max_value)

@export var max_stamina := 100.0
@export var drain_rate := 20.0
@export var regen_rate := 12.0
@export var regen_delay := 0.0

var current: float
var _regen_timer: float = 0.0
var _depleting: bool = false

func _ready():
    current = max_stamina

func _process(delta: float):
    if _depleting:
        current = max(0.0, current - drain_rate * delta)
        _regen_timer = 0.0
        if current <= 0.0:
            _depleting = false
    else:
        if current < max_stamina:
            _regen_timer += delta
            if _regen_timer >= regen_delay:
                current = min(max_stamina, current + regen_rate * delta)

    stamina_changed.emit(current, max_stamina)

func start_deplete():
    _depleting = true

func stop_deplete():
    _depleting = false
    _regen_timer = 0.0

func has_stamina() -> bool:
    return current > 0.0

func consume(amount: float) -> bool:
    if current >= amount:
        current -= amount
        stamina_changed.emit(current, max_stamina)
        _regen_timer = 0.0
        return true
    return false
