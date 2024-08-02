class_name PlayerCharacterAnimations extends Node2D

@onready var character : CharacterBody2D = owner
@onready var controller : SimplePlatformerController = %SimplePlatformerController
@onready var polygon : Polygon2D = character.get_node('CollisionWithPolygon2D/AutoPolygonCollisionWithPolygon2D')

var jump_tween : Tween

func _ready() -> void:
  controller.sig_jump_started.connect(on_jump_started)
  controller.sig_jump_landed.connect(on_jump_landed)

func on_jump_started():
  if jump_tween: jump_tween.kill()
  jump_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
  jump_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
  jump_tween.tween_property(polygon, 'scale', Vector2(1.2, 0.8), 0.1).from(Vector2(1,1))
  jump_tween.tween_property(polygon, 'scale', Vector2(0.8, 1.2), 0.1)
  jump_tween.tween_property(polygon, 'scale', Vector2(1, 1), 0.1)

func on_jump_landed():
  if jump_tween: jump_tween.kill()
  jump_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
  jump_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
  jump_tween.tween_property(polygon, 'scale', Vector2(1.2, 0.8), 0.1).from(Vector2(1,1))
  jump_tween.tween_property(polygon, 'scale', Vector2(1, 1), 0.1)

func _physics_process(_delta: float) -> void:
  if is_zero_approx(character.velocity.x):
    character.skew = 0.0
  elif not character.is_on_floor():
    character.skew = 0.0
  else:
    character.skew = sign(character.velocity.x) * deg_to_rad(10) * -1
