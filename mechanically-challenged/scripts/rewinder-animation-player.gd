class_name MechanicallyChallengedRewinderAnimationPlayer extends AnimationPlayer

const INPUT_REWIND := &'rewind'
const LIBRARY_NAME := 'rewinder'
const ANIMATION_NAME := 'rewind'
const ANIMATION_PLAYER_NAME := 'RewinderAnimationPlayer'
const ANIMATION_PLAYER_GROUP := &'rewinder-animation-player'

var overlay_layer : CanvasLayer
var overlay_rect : ColorRect

static func singleton() -> MechanicallyChallengedRewinderAnimationPlayer:
  var tree := Engine.get_main_loop() as SceneTree
  if tree:
    var existing = tree.get_first_node_in_group(ANIMATION_PLAYER_GROUP) as AnimationPlayer
    if existing: return existing
    var created := MechanicallyChallengedRewinderAnimationPlayer.new()
    tree.current_scene.add_child.call_deferred(created)
  return null

func _ready() -> void:
  add_to_group(ANIMATION_PLAYER_GROUP)
  process_mode = ProcessMode.PROCESS_MODE_ALWAYS
  name = ANIMATION_PLAYER_NAME
  root_node = ^'..'
  process_mode = ProcessMode.PROCESS_MODE_ALWAYS
  name = ANIMATION_PLAYER_NAME
  add_animation_library(LIBRARY_NAME, AnimationLibrary.new())
  create_overlay()
  animation_finished.connect(on_animation_finished)
  animation_started.connect(on_animation_started)

func create_overlay():
  overlay_layer = CanvasLayer.new()
  overlay_rect = ColorRect.new()
  overlay_rect.color = Color.GRAY
  overlay_rect.color.a = 0.0
  overlay_rect.set_anchors_and_offsets_preset(Control.LayoutPreset.PRESET_FULL_RECT, Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE)
  overlay_layer.add_child(overlay_rect)
  get_tree().current_scene.add_child.call_deferred(overlay_layer)

func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed(INPUT_REWIND):
    start_rewind()

func pause_and_grayout():
  get_tree().paused = true
  overlay_rect.color.a = 0.2

func unpause_and_clear():
  overlay_rect.color.a = 0.0
  get_tree().paused = false

func on_animation_started(_animation_name:StringName):
  print_verbose('started rewinding')

func on_animation_finished(_animation_name:StringName):
  print_verbose('finished rewinding')
  clear_animation()
  reset_rewinders()
  unpause_and_clear()

func start_rewind():
  pause_and_grayout()
  add_animation_to_library(create_animation())
  play_backwards('%s/%s' % [LIBRARY_NAME, ANIMATION_NAME])

func create_animation() -> Animation:
  var animation = Animation.new()
  animation.length = 0.01
  for rewinder in MechanicallyChallengedRewinder.all():
    if rewinder.max_time_in_seconds > animation.length: animation.length = rewinder.max_time_in_seconds
    rewinder.prepare_rewind(animation)
  return animation

func reset_rewinders():
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.reset()

func clear_animation():
  var library := get_animation_library(LIBRARY_NAME)
  if library.has_animation(ANIMATION_NAME): library.remove_animation(ANIMATION_NAME)

func add_animation_to_library(animation:Animation):
  var library := get_animation_library(LIBRARY_NAME)
  if library.has_animation(ANIMATION_NAME): library.remove_animation(ANIMATION_NAME)
  library.add_animation(ANIMATION_NAME, animation)
