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
  print_verbose('setting up rewind track for %s' % target_path)
  var track_index := animation.add_track(Animation.TrackType.TYPE_VALUE)
  animation.track_set_path(track_index, target_path) 
  var delta_t := 1.0 / resoltion_fps
  var initial_index := pointer - 0
  if initial_index < 0: initial_index = values.size() - 1
  for i in values.size() - 0:
    var idx := (initial_index + i) % values.size()
    var val = values[idx]
    if val == null: continue
    var t = i * delta_t
    animation.track_insert_key(track_index, t, val)

func prepare_rewind(animation:Animation):
  mode = RewinderMode.REWIND
  set_physics_process(mode == RewinderMode.RECORD)
  setup_rewind_track_for(animation, ':position', positions)
  setup_rewind_track_for(animation, ':skew', skews)
  setup_rewind_track_for(animation, ':rotation', rotations)
  setup_rewind_track_for(animation, ':scale', scales)

func reset(new_mode:RewinderMode=RewinderMode.RECORD):
  var number_of_frames := roundi(max_time_in_seconds * resoltion_fps)
  pointer = 0
  positions = []
  scales = []
  skews = []
  rotations = []
  positions.resize(number_of_frames)
  scales.resize(number_of_frames)
  skews.resize(number_of_frames)
  rotations.resize(number_of_frames)
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
  add_to_group(REWINDER_GROUP)
  target.process_mode = ProcessMode.PROCESS_MODE_PAUSABLE
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
  var tree := Engine.get_main_loop() as SceneTree
  var res : Array[MechanicallyChallengedRewinder] = []
  if tree: for r in tree.get_nodes_in_group(REWINDER_GROUP): res.push_back(r)
  return res
