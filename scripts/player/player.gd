
extends CharacterBody2D

@export var speed: float = 400.0
@export var jump_velocity: float = -650.0
@export var gravity: float = 1500.0
@export var max_health: int = 200

@onready var sprite: Sprite2D = $Sprite2D

var health: int
var dead: bool = false
var attack_cooldown: float = 0.0


func _ready() -> void:
	add_to_group("players")
	health = max_health
	print("JAADU READY")


func _physics_process(delta: float) -> void:
	if dead:
		velocity = Vector2.ZERO
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if direction != 0.0:
		sprite.flip_h = direction < 0.0

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	attack_cooldown = maxf(0.0, attack_cooldown - delta)

	if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
		attack()

	move_and_slide()


func attack() -> void:
	var target: Node2D = null
	var closest_distance: float = 650.0

	for item in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(item) or not item is Node2D:
			continue

		var candidate := item as Node2D

		if bool(candidate.get("dead")):
			continue

		var distance := global_position.distance_to(candidate.global_position)

		if distance < closest_distance:
			closest_distance = distance
			target = candidate

	if target == null:
		print("NO ENEMY FOUND - CHECK ENEMY SCRIPT")
		return

	if not target.has_method("take_damage"):
		print("ENEMY HAS NO TAKE_DAMAGE METHOD")
		return

	attack_cooldown = 0.55

	var direction := signf(target.global_position.x - global_position.x)
	if direction == 0.0:
		direction = 1.0

	# Jaadu attack animation: rotation only. No zoom or scaling.
	var swing := create_tween()
	swing.tween_property(sprite, "rotation", -0.18 * direction, 0.06)
	swing.tween_property(sprite, "rotation", 0.0, 0.10)

	# Create a world-space projectile with a comic-style label.
	var projectile := Node2D.new()
	var label := Label.new()

	label.text = "THAPPAD!"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 7)
	label.position = Vector2(-75, -25)
	label.size = Vector2(150, 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	projectile.add_child(label)
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position + Vector2(direction * 65.0, -110.0)

	var destination := target.global_position + Vector2(0, -100.0)

	var flight := get_tree().create_tween()
	flight.tween_property(projectile, "global_position", destination, 0.18)

	flight.finished.connect(func():
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.call("take_damage", 20)

		if is_instance_valid(projectile):
			projectile.queue_free()
	)


func take_damage(amount: int) -> void:
	if dead:
		return

	health = maxi(0, health - amount)
	print("JAADU HEALTH: ", health)

	var flash := create_tween()
	flash.tween_property(sprite, "modulate", Color.RED, 0.07)
	flash.tween_property(sprite, "modulate", Color.WHITE, 0.13)

	if health <= 0:
		dead = true
		velocity = Vector2.ZERO
		show_message("JAADU DEFEATED!")


func show_message(message: String) -> void:
	var layer := CanvasLayer.new()
	get_tree().current_scene.add_child(layer)

	var label := Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color.RED)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)

	layer.add_child(label)
	label.size = Vector2(600, 90)
	label.position = (get_viewport_rect().size - label.size) / 2.0
