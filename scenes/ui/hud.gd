extends CanvasLayer

@onready var mode_label: Label = $MarginContainer/VBoxContainer/ModeLabel
@onready var controls_label: Label = $MarginContainer/VBoxContainer/ControlsLabel

func set_mode_text(mode_name: String) -> void:
	if mode_label:
		mode_label.text = "Mode: " + mode_name
