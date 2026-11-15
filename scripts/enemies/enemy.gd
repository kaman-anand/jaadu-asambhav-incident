
extends Sprite2D

@export var max_health: int = 150
@export var move_speed: float = 115.0
@export var attack_range: float = 130.0
@export var attack_damage: int = 8

var health: int
var player: Node2D = null
var attack_timer: float = 1.0
var dead: bool = false


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	print("ENEMY READY: ", name)


func _process(delta: float) -> void:
	if dead:
		return

	if not is_instance_valid(player):
		var players := get_tree().get_nodes_in_group("players")

		if players.is_empty():
			return

		player = players[0] as Node2D

	if not is_instance_valid(player):
		return

	if bool(player.get("dead")):
		return

	var distance := player.global_position.x - global_position.x

	if absf(distance) > attack_range:
		var stopping_point := player.global_position.x - signf(distance) * attack_range

		global_position.x = move_toward(
			global_position.x,
			stopping_point,
			move_speed * delta
		)

		flip_h = distance < 0.0
	else:
		attack_timer -= delta

		if attack_timer <= 0.0:
			attack_player()


func attack_player() -> void:
	attack_timer = 1.5

	# Small attack movement, without changing scale.
	var direction := signf(player.global_position.x - global_position.x)
	if direction == 0.0:
		direction = 1.0

	var swing := create_tween()
	swing.tween_property(self, "rotation", 0.12 * direction, 0.07)
	swing.tween_property(self, "rotation", 0.0, 0.12)

	if player.has_method("take_damage"):
		player.call("take_damage", attack_damage)


func take_damage(amount: int) -> void:
	if dead:
		return

	health = maxi(0, health - amount)
	print("ENEMY HEALTH: ", health)

	var direction := 1.0

	if is_instance_valid(player):
		direction = signf(global_position.x - player.global_position.x)

	if direction == 0.0:
		direction = 1.0

	global_position.x += direction * 40.0

	var hit := create_tween()
	hit.tween_property(self, "modulate", Color.RED, 0.07)
	hit.tween_property(self, "modulate", Color.WHITE, 0.13)

	if health <= 0:
		dead = true
		show_victory()
		queue_free()


func show_victory() -> void:
	var layer := CanvasLayer.new()
	get_tree().current_scene.add_child(layer)

	var label := Label.new()
	label.text = "ENEMY DEFEATED!"
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)

	layer.add_child(label)
	label.size = Vector2(600, 90)
	label.position = (get_viewport_rect().size - label.size) / 2.0
