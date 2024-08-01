@tool
## Automatically Creates Polygon2D matching its shape
class_name CollisionWithPolygon2D extends CollisionPolygon2D

## Automatically run the toolscript setup everytime you save the scene
func _notification(what: int) -> void: ToolScriptHelpers.on_pre_save(what, tool_setup_if_needed)

## Creates a Polygon2D matching the vertices of the CollisionPolygon2D (col) as a child of the Node (parent)
static func create_polygon_for_collider(col:CollisionPolygon2D, parent:Node):
  var pol := Polygon2D.new()
  pol.polygon = col.polygon.duplicate()
  pol.name = 'AutoPolygon%s' % col.name
  pol.color = col.modulate
  parent.add_child.call_deferred(pol)
  await pol.ready
  if Engine.is_editor_hint(): pol.owner = parent.get_tree().edited_scene_root

func tool_setup_if_needed():
  if not ToolScriptHelpers.is_valid_tool_target(self): return

  await ToolScriptHelpers.remove_all_polygon2d_children(self)

  create_polygon_for_collider(self, self)
