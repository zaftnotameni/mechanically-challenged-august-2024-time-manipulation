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
    print_verbose('input rewind')
    start_rewind()

func pause_and_grayout():
  print_verbose('START pause_and_grayout')
  # get_tree().paused = true
  pause_rewinders()
  overlay_rect.color.a = 0.2
  print_verbose('END pause_and_grayout')

func unpause_and_clear():
  print_verbose('START unpause_and_clear')
  overlay_rect.color.a = 0.0
  # get_tree().paused = false
  unpause_rewinders()
  print_verbose('END unpause_and_clear')

func on_animation_started(_animation_name:StringName):
  print_verbose('started rewinding')

func on_animation_finished(_animation_name:StringName):
  print_verbose('finished rewinding')
  clear_animation()
  reset_rewinders.call_deferred()
  unpause_and_clear.call_deferred()

func start_rewind():
  print_verbose('START start_rewind')
  pause_and_grayout()
  # add_animation_to_library.call_deferred(create_animation())
  create_animation()
  play_animation.call_deferred()
  print_verbose('END start_rewind')

func create_animation() -> Animation:
  print_verbose('START create_animation')
  var animation : Animation

  if get_animation_library(LIBRARY_NAME).has_animation(ANIMATION_NAME):
    animation = get_animation_library(LIBRARY_NAME).get_animation(ANIMATION_NAME)
  else:
    animation = Animation.new()
    get_animation_library(LIBRARY_NAME).add_animation(ANIMATION_NAME, animation)

  animation.length = 0.01
  for rewinder in MechanicallyChallengedRewinder.all():
    if rewinder.max_time_in_seconds > animation.length: animation.length = rewinder.max_time_in_seconds
    rewinder.prepare_rewind(animation)
  print_verbose('END create_animation')
  ResourceSaver.save(animation, 'res://animation.tres')
  return animation

func pause_rewinders():
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.target.process_mode = ProcessMode.PROCESS_MODE_DISABLED

func unpause_rewinders():
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.target.process_mode = ProcessMode.PROCESS_MODE_INHERIT

func reset_rewinders():
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.reset()

func clear_animation():
  print_verbose('START clear_animation')
  var library := get_animation_library(LIBRARY_NAME)
  if library.has_animation(ANIMATION_NAME): library.remove_animation(ANIMATION_NAME)
  print_verbose('END clear_animation')

func play_animation():
  print_verbose('START play_animation')
  await get_tree().create_timer(0.1).timeout
  play('%s/%s' % [LIBRARY_NAME, ANIMATION_NAME])
  print_verbose('END play_animation')

func add_animation_to_library(animation:Animation):
  print_verbose('START add_animation_to_library')
  var library := get_animation_library(LIBRARY_NAME)
  if library.has_animation(ANIMATION_NAME): library.remove_animation(ANIMATION_NAME)
  library.add_animation(ANIMATION_NAME, animation)
  ResourceSaver.save(library, 'res://library.tres')
  print_verbose('END add_animation_to_library')
