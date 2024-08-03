class_name MechanicallyChallengedRewinder extends Node2D

enum RewinderMode { RECORD, REWIND }
enum NY { No, Yes }

@export_group('target')
## defaults to the scene root if not set
@export var target : Node2D

@export_group('timing')
@export var max_time_in_seconds : float = 2.0
@export var resoltion_fps : int = 30

@export_group('tracks')
@export var tracks_position : NY = NY.Yes
@export var tracks_rotation : NY
@export var tracks_skew : NY
@export var tracks_scale : NY

const REWINDER_GROUP := &'rewinder'

var number_of_frames : int

var mode : RewinderMode
var scales : Array
var positions : Array
var skews : Array
var rotations : Array
var pointer : int

func tween_for_rewind_track() -> Tween:
  var tween := create_tween()
  tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
  tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
  return tween

func setup_rewind_track_for(selector:String=':position', values:Array=positions) -> Tween:
  var tween = tween_for_rewind_track()
  var delta_t := 1.0 / resoltion_fps
  var initial_index := pointer - 0
  if initial_index < 0: initial_index = values.size() - 1
  if initial_index > values.size() - 1: initial_index = 0
  for i in values.size() - 0:
    var idx := (initial_index - i - 1)
    var val = values[idx]
    if val == null: continue
    tween.tween_property(target, selector, val, delta_t)
  return tween

func prepare_rewind() -> Array[Tween]:
  var tweens : Array[Tween] = []
  mode = RewinderMode.REWIND
  set_physics_process(mode == RewinderMode.RECORD)
  tweens.push_back(setup_rewind_track_for(':position', positions))
  tweens.push_back(setup_rewind_track_for(':skew', skews))
  tweens.push_back(setup_rewind_track_for(':scale', scales))
  tweens.push_back(setup_rewind_track_for(':rotation', rotations))
  return tweens

func reset(new_mode:RewinderMode=RewinderMode.RECORD):
  pointer = 0
  if tracks_rotation == NY.Yes: rotations.fill(null)
  if tracks_position == NY.Yes: positions.fill(null)
  if tracks_skew == NY.Yes: skews.fill(null)
  if tracks_scale == NY.Yes: scales.fill(null)
  mode = new_mode
  set_physics_process(mode == RewinderMode.RECORD)

func _physics_process(_delta: float) -> void:
  if mode == RewinderMode.RECORD:
    record_position()
    record_skew()
    record_rotation()
    record_scale()
    pointer = (pointer + 1) % positions.size()

func _ready() -> void:
  if not target: target = owner
  add_to_group(REWINDER_GROUP)
  target.process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
  init_databags()
  reset()
  MechanicallyChallengedRewinderCentralController.singleton()

func path_to_target(selector:String='') -> String:
  return str(get_tree().current_scene.get_path_to(target)) + selector

func record_rotation():
  if tracks_rotation == NY.No: return
  rotations[pointer % positions.size()] = target.rotation

func record_skew():
  if tracks_skew == NY.No: return
  skews[pointer % positions.size()] = target.skew

func record_position():
  if tracks_position == NY.No: return
  positions[pointer % positions.size()] = target.position

func record_scale():
  if tracks_scale == NY.No: return
  scales[pointer % scales.size()] = target.scale

func init_databags():
  number_of_frames = roundi(max_time_in_seconds * resoltion_fps)
  init_position()
  init_skew()
  init_rotation()
  init_scale()

func init_position():
  if tracks_position == NY.No: return
  positions = []
  positions.resize(number_of_frames)

func init_skew():
  if tracks_skew == NY.No: return
  skews = []
  skews.resize(number_of_frames)

func init_rotation():
  if tracks_rotation == NY.No: return
  rotations = []
  rotations.resize(number_of_frames)

func init_scale():
  if tracks_scale == NY.No: return
  scales = []
  scales.resize(number_of_frames)

static func all() -> Array[MechanicallyChallengedRewinder]:
  var tree := Engine.get_main_loop() as SceneTree
  var res : Array[MechanicallyChallengedRewinder] = []
  if tree: for r in tree.get_nodes_in_group(REWINDER_GROUP): res.push_back(r)
  return res
