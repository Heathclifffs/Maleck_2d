extends Node2D

@onready var riale := $Riale
@onready var info := $UI/InfoLabel as Label

var hp_text := ""
var stamina_text := ""

func _ready():
    riale.get_node("Health").health_changed.connect(_on_health_changed)
    riale.get_node("Stamina").stamina_changed.connect(_on_stamina_changed)
    _on_health_changed(riale.get_node("Health").current_hp, riale.get_node("Health").max_hp)
    _on_stamina_changed(riale.get_node("Stamina").current, riale.get_node("Stamina").max_stamina)

func _process(_delta: float):
    var dir_name: String = riale.direction.capitalize().replace("_", " ")
    var state_names := {0: "Idle", 1: "Walk", 2: "Run"}
    var state_name: String = state_names.get(riale.state, "?")
    var sprint_tag := " [SPRINT]" if riale.is_sprinting else ""
    info.text = state_name + " " + dir_name + sprint_tag + hp_text + stamina_text

    if Input.is_action_just_pressed("ui_accept"):
        riale.get_node("Health").take_damage(1)
    if Input.is_action_just_pressed("ui_focus_next"):
        riale.get_node("Health").heal(2)
    if Input.is_action_just_pressed("ui_cancel"):
        riale.get_node("Health").take_damage(10)

func _on_health_changed(hp, mhp):
    hp_text = "   HP: %d/%d" % [hp, mhp]

func _on_stamina_changed(st, mst):
    stamina_text = "   ST: %d/%d" % [st, mst]
