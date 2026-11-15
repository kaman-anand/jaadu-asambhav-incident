
extends CanvasLayer

var player: Node
var enemy: Node

var player_title: Label
var enemy_title: Label
var player_bar: ProgressBar
var enemy_bar: ProgressBar
var level_title: Label
var status_label: Label


func _ready() -> void:
	create_hud()


func create_hud() -> void:
	var screen_width := get_viewport().get_visible_rect().size.x

	# Player panel
	make_panel(Vector2(25, 22), Vector2(355, 88))
	player_title = make_label("JAADU", Vector2(42, 28), Vector2(320, 28), 22)
	player_bar = make_bar(Vector2(42, 62), Vector2(320, 20))

	# Enemy panel
	make_panel(Vector2(screen_width - 380, 22), Vector2(355, 88))
	enemy_title = make_label("ENEMY", Vector2(screen_width - 362, 28), Vector2(320, 28), 22)
	enemy_bar = make_bar(Vector2(screen_width - 362, 62), Vector2(320, 20))

	# Level title
	level_title = make_label(
		"JAADU: THE ASAMBHAV INCIDENT",
		Vector2(screen_width / 2.0 - 250, 28),
		Vector2(500, 38),
		23
	)
	level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Status
	status_label = make_label(
		"LEVEL 1  |  THE FIRST FIGHT",
		Vector2(screen_width / 2.0 - 250, 75),
		Vector2(500, 35),
		17
	)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Controls
	var controls := make_label(
		"A / D  MOVE     SPACE  JUMP     J  THAPPAD",
		Vector2(25, get_viewport().get_visible_rect().size.y - 45),
		Vector2(650, 30),
		18
	)
	controls.add_theme_color_override("font_color", Color.WHITE)


func make_panel(pos: Vector2, dimensions: Vector2) -> void:
	var panel := ColorRect.new()
	panel.position = pos
	panel.size = dimensions
	panel.color = Color(0.025, 0.035, 0.06, 0.88)
	add_child(panel)


func make_label(
	content: String,
	pos: Vector2,
	dimensions: Vector2,
	font_size: int
) -> Label:
	var label := Label.new()
	label.text = content
	label.position = pos
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	add_child(label)
	return label


func make_bar(pos: Vector2, dimensions: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = dimensions
	bar.min_value = 0
	bar.max_value = 200
	bar.value = 200
	bar.show_percentage = false

	var back := StyleBoxFlat.new()
	back.bg_color = Color(0.15, 0.15, 0.18)
	bar.add_theme_stylebox_override("background", back)

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.85, 0.12, 0.08)
	bar.add_theme_stylebox_override("fill", fill)

	add_child(bar)
	return bar


func _process(_delta: float) -> void:
	var players := get_tree().get_nodes_in_group("players")
	var enemies := get_tree().get_nodes_in_group("enemies")

	if not players.is_empty():
		player = players[0]

	if is_instance_valid(player):
		var hp := int(player.get("health"))
		var maximum := 200

		var max_property = player.get("max_health")
		if max_property != null:
			maximum = int(max_property)

		player_bar.max_value = maximum
		player_bar.value = hp
		player_title.text = "JAADU  %d / %d" % [hp, maximum]

		if bool(player.get("dead")):
			status_label.text = "JAADU HAS FALLEN"
			status_label.add_theme_color_override("font_color", Color.RED)

	if not enemies.is_empty():
		enemy = enemies[0]

	if is_instance_valid(enemy):
		var hp := int(enemy.get("health"))
		var maximum := int(enemy.get("max_health"))

		enemy_bar.max_value = maximum
		enemy_bar.value = hp
		enemy_title.text = "ENEMY  %d / %d" % [hp, maximum]
	else:
		enemy_bar.value = 0
		enemy_title.text = "ENEMY DEFEATED"
		if not is_instance_valid(player) or not bool(player.get("dead")):
			status_label.text = "ARENA CLEAR!"
