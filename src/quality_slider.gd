extends HSlider

@onready var selected_quality_lbl: Label = $"../Panel/SelectedQualityLbl"

func _on_value_changed(newValue: float) -> void:
	var intValue = int(newValue)
	selected_quality_lbl.text = str(intValue)
	Encoding.selectedCRF = intValue
