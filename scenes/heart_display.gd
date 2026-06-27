extends Control

@export var heart_size := 20
@export var heart_spacing := 2
@export var hearts_per_row := 5
@export var offset := Vector2(12, 12)

var max_hearts := 0
var current_hp := 0
var hearts: Array[Label] = []

func _ready():
    var hp = get_node("/root/Main/Riale/Health")
    hp.health_changed.connect(_on_health_changed)
    _on_health_changed(hp.current_hp, hp.max_hp)

func _on_health_changed(hp, mhp):
    current_hp = hp
    max_hearts = mhp / 2
    rebuild()

func rebuild():
    for h in hearts:
        h.queue_free()
    hearts.clear()

    for i in range(max_hearts):
        var row = i / hearts_per_row
        var col = i % hearts_per_row
        var x = offset.x + col * (heart_size + heart_spacing)
        var y = offset.y + row * (heart_size + heart_spacing)

        var label = Label.new()
        label.text = "♥"
        label.add_theme_font_size_override("font_size", heart_size)
        label.position = Vector2(x, y)
        label.size = Vector2(heart_size + 4, heart_size + 4)

        var filled := false
        var half := false
        if i < current_hp / 2:
            filled = true
        elif i == current_hp / 2:
            half = current_hp % 2 == 1

        if filled:
            label.add_theme_color_override("font_color", Color(1.0, 0.15, 0.15))
        elif half:
            label.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5))
        else:
            label.add_theme_color_override("font_color", Color(0.2, 0.06, 0.06))

        add_child(label)
        hearts.append(label)
