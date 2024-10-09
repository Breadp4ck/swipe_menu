@tool
extends EditorPlugin


const EMULATE_TOUCH_FROM_MOUSE_WARN_TEXT := "The option \"input_devices/pointing/emulate_touch_from_mouse\" is not activated. The mouse dragging will be ignored."


func _enter_tree() -> void:
	var emulate_touch_from_mouse: bool = ProjectSettings.get("input_devices/pointing/emulate_touch_from_mouse")
	if not emulate_touch_from_mouse:
		push_warning(EMULATE_TOUCH_FROM_MOUSE_WARN_TEXT)


func _exit_tree() -> void:
	pass
