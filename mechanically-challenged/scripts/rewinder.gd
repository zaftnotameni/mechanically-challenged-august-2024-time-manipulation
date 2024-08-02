class_name MechanicallyChallengedRewinder extends Node2D

enum RewinderMode { RECORD, REWIND }

@export var max_time_in_seconds : float = 2.0
@export var resoltion_fps : int = 30

const REWINDER_GROUP := &'rewinder'

@onready var target : Node2D = owner

var mode : RewinderMode
var scales : Array
var positions : Array
var skews : Array
var rotations : Array
var pointer : int

func setup_rewind_track_for(animation:Animation, selector:String=':position', values:Array=positions):
  var target_path := path_to_target(selector)
  print_verbose('START setting up rewind track for %s' % target_path)
  var track_index := animation.add_track(Animation.TrackType.TYPE_VALUE)
  animation.track_set_path(track_index, target_path) 
  for k in animation.track_get_key_count(track_index): animation.track_remove_key(track_index, k)
  var delta_t := 1.0 / resoltion_fps
  var initial_index := pointer - 0
  if initial_index < 0: initial_index = values.size() - 1
  if initial_index > values.size() - 1: initial_index = 0
  for i in values.size() - 0:
    var idx := (initial_index + i) % values.size()
    var val = values[idx]
    if val == null: continue
    var t = i * delta_t
    print_verbose('value %s at time %s' % [val, t])
    animation.track_insert_key(track_index, max_time_in_seconds - t, val)
  print_verbose('END setting up rewind track for %s' % target_path)

func prepare_rewind(animation:Animation):
  mode = RewinderMode.REWIND
  set_physics_process(mode == RewinderMode.RECORD)
  setup_rewind_track_for(animation, ':position', positions)
  # setup_rewind_track_for(animation, ':skew', skews)
  # setup_rewind_track_for(animation, ':rotation', rotations)
  # setup_rewind_track_for(animation, ':scale', scales)

func reset(new_mode:RewinderMode=RewinderMode.RECORD):
  print_verbose('START reset')
  # pointer = 0
  # positions.fill(null)
  # scales.fill(null)
  # skews.fill(null)
  # rotations.fill(null)
  mode = new_mode
  set_physics_process(mode == RewinderMode.RECORD)
  print_verbose('END reset')

func _physics_process(_delta: float) -> void:
  if mode == RewinderMode.RECORD:
    record_position()
    # record_skew()
    # record_rotation()
    # record_scale()
    pointer = (pointer + 1) % positions.size()

func _ready() -> void:
  add_to_group(REWINDER_GROUP)
  target.process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
  positions = []
  scales = []
  skews = []
  rotations = []
  var number_of_frames := roundi(max_time_in_seconds * resoltion_fps)
  positions.resize(number_of_frames)
  scales.resize(number_of_frames)
  skews.resize(number_of_frames)
  rotations.resize(number_of_frames)
  reset()
  MechanicallyChallengedRewinderAnimationPlayer.singleton()

func path_to_target(selector:String='') -> String:
  return str(get_tree().current_scene.get_path_to(target)) + selector

func record_rotation():
  rotations[pointer % positions.size()] = target.rotation

func record_skew():
  skews[pointer % positions.size()] = target.skew

func record_position():
  positions[pointer % positions.size()] = target.position

func record_scale():
  scales[pointer % scales.size()] = target.scale

static func all() -> Array[MechanicallyChallengedRewinder]:
  print_verbose('START all')
  var tree := Engine.get_main_loop() as SceneTree
  var res : Array[MechanicallyChallengedRewinder] = []
  if tree: for r in tree.get_nodes_in_group(REWINDER_GROUP): res.push_back(r)
  print_verbose('END all')
  return res
