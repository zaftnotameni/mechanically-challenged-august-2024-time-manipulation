class_name SimplePlatformerController extends Node2D

signal sig_jump_started()
signal sig_jump_landed()

@export var speed : float = 100.0
@export var jump_time_to_peak : float = 0.6 : set = set_jump_time_to_peak
@export var jump_time_to_land : float = 0.4 : set = set_jump_time_to_land
@export var jump_height: float = 64.0 : set = set_jump_height

const INPUT_LEFT := &'player-left'
const INPUT_RIGHT := &'player-right'
const INPUT_DOWN := &'player-down'
const INPUT_UP := &'player-up'
const INPUT_JUMP := &'player-jump'

@onready var character : CharacterBody2D = owner

func _physics_process(delta: float) -> void:
  var was_on_floor = character.is_on_floor()
  apply_horizontal_movement()
  apply_gravity(delta)
  character.move_and_slide()
  var is_on_floor = character.is_on_floor()
  if not was_on_floor and is_on_floor: sig_jump_landed.emit()

func _unhandled_input(event: InputEvent) -> void:
  if character.is_on_floor() and event.is_action_pressed(INPUT_JUMP):
    apply_jump()

func _ready() -> void:
  run_kinematic_equations()

func apply_jump():
  sig_jump_started.emit()
  character.velocity.y = -jump_initial_speed

func apply_horizontal_movement():
  var input_x = Input.get_axis(INPUT_LEFT, INPUT_RIGHT)
  character.velocity.x = input_x * speed

func apply_gravity(delta:float):
  var is_going_down = character.velocity.y > 0
  var is_going_up = character.velocity.y <= 0
  if character.is_on_floor():
    return
  elif not Input.is_action_pressed(INPUT_JUMP):
    character.velocity.y += gravity_down * delta
  elif is_going_down:
    character.velocity.y += gravity_down * delta
  elif is_going_up:
    character.velocity.y += gravity_up * delta

var jump_initial_speed : float
var gravity_up : float
var gravity_down : float

func run_kinematic_equations():
  jump_initial_speed = (2.0 * jump_height) / jump_time_to_peak
  gravity_up = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
  gravity_down = (2.0 * jump_height) / (jump_time_to_land * jump_time_to_land)

func set_jump_time_to_peak(new_val:float): float_setter(&'jump_time_to_peak', new_val)
func set_jump_time_to_land(new_val:float): float_setter(&'jump_time_to_land', new_val)
func set_jump_height(new_val:float): float_setter(&'jump_height', new_val)

func float_setter(property_name:StringName, new_val:float) -> bool:
  var old_val = get(property_name)
  if is_equal_approx(new_val, old_val): return false
  set(property_name, new_val)
  run_kinematic_equations()
  queue_redraw()
  return true
