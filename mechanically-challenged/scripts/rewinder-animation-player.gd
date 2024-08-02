class_name MechanicallyChallengedRewinderCentralController extends Node2D

const INPUT_REWIND := &'rewind'
const ANIMATION_PLAYER_NAME := 'RewinderAnimationPlayer'
const ANIMATION_PLAYER_GROUP := &'rewinder-animation-player'

var overlay_layer : CanvasLayer
var overlay_rect : ColorRect
var counter : int = 0
var tweens : Array[Tween]

static func singleton() -> MechanicallyChallengedRewinderCentralController:
  var tree := Engine.get_main_loop() as SceneTree
  if tree:
    var existing = tree.get_first_node_in_group(ANIMATION_PLAYER_GROUP) as AnimationPlayer
    if existing: return existing
    var created := MechanicallyChallengedRewinderCentralController.new()
    tree.current_scene.add_child.call_deferred(created)
  return null

func _ready() -> void:
  counter = 0
  tweens = []
  add_to_group(ANIMATION_PLAYER_GROUP)
  process_mode = ProcessMode.PROCESS_MODE_ALWAYS
  name = ANIMATION_PLAYER_NAME
  create_overlay()

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
  pause_rewinders()
  overlay_rect.color.a = 0.2

func unpause_and_clear():
  overlay_rect.color.a = 0.0
  unpause_rewinders()

func on_rewind_started():
  counter = 0
  tweens.clear()
  pause_and_grayout()

func on_rewind_finished():
  reset_rewinders()
  unpause_and_clear()

func count_tween_finished():
  counter += 1
  if counter >= tweens.size():
    on_rewind_finished()

func start_rewind():
  on_rewind_started()
  tween_rewind()

func tween_rewind():
  for rewinder in MechanicallyChallengedRewinder.all():
    for tween in rewinder.prepare_rewind():
      tween.finished.connect(count_tween_finished)
      tweens.push_back(tween)

func pause_rewinders():
  get_tree().paused = true
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.target.process_mode = ProcessMode.PROCESS_MODE_DISABLED

func unpause_rewinders():
  get_tree().paused = false
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.target.process_mode = ProcessMode.PROCESS_MODE_INHERIT

func reset_rewinders():
  for rewinder in MechanicallyChallengedRewinder.all(): rewinder.reset()
