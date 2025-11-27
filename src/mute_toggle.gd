extends CheckBox


func _on_toggled(toggled_on: bool) -> void:
	Encoding.mute = toggled_on
