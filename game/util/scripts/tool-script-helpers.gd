@tool
class_name ToolScriptHelpers extends Node

static func on_pre_save(what: int, fn:Callable) -> void: if what == NOTIFICATION_EDITOR_PRE_SAVE: await fn.call()

static func is_valid_tool_target(node:Node) -> bool:
  if not node: return false
  if not node.get_tree(): return false
  if not Engine.is_editor_hint(): return false
  if node.get_tree().edited_scene_root != node.owner: return false
  return true

static func remove_all_polygon2d_children(node:Node):
  if not is_valid_tool_target(node): return
  for child:Node in node.get_children():
    if child is Polygon2D:
      child.queue_free()
      await child.tree_exited
