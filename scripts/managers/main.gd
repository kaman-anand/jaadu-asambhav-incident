
extends Node2D


func _ready() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "GameUI"
	add_child(ui_layer)

	var restart_button := Button.new()
	restart_button.name = "RestartButton"
	restart_button.text = "RESTART"

	restart_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	restart_button.position = Vector2(-180, 24)
	restart_button.size = Vector2(155, 48)

	restart_button.add_theme_font_size_override("font_size", 20)

	ui_layer.add_child(restart_button)
	restart_button.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
