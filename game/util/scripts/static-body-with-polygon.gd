@tool
## Automatically Creates Polygon2D entries for each CollisionPolygon2D child
class_name StaticBodyWithPolygon2D extends StaticBody2D

## Automatically run the toolscript setup everytime you save the scene
func _notification(what: int) -> void: ToolScriptHelpers.on_pre_save(what, tool_setup_if_needed)

func tool_setup_if_needed():
  if not ToolScriptHelpers.is_valid_tool_target(self): return

  await ToolScriptHelpers.remove_all_polygon2d_children(self)

  # for each CollisionPolygon2D, automatically create a Polygon2D matching it
  for child:Node in get_children():
    if child is CollisionPolygon2D:
      CollisionWithPolygon2D.create_polygon_for_collider(child, self)
