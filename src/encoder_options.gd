extends OptionButton

@onready var quality_slider: HSlider = $"../QualityValuePanel/QualitySlider"
@onready var min_quality_lbl: Label = $"../QualityValuePanel/Panel/MinQualityLbl"
@onready var max_quality_lbl: Label = $"../QualityValuePanel/Panel/MaxQualityLbl"
@onready var selected_quality_lbl: Label = $"../QualityValuePanel/Panel/SelectedQualityLbl"

func _on_ready() -> void:
	for encoding in Encoding.Codecs.keys():
		add_item(encoding, Encoding.Codecs[encoding])
	select(Encoding.Codecs.H265)
	_on_item_selected(1)


func _on_item_selected(index: int) -> void:
	var newCodec = Encoding.Codecs[Encoding.Codecs.find_key(index)]
	Encoding.selectCodec(newCodec)
	quality_slider.min_value = Encoding.ENCODING_CONFIGS[newCodec].minCRF
	min_quality_lbl.text = str(Encoding.ENCODING_CONFIGS[newCodec].minCRF)

	quality_slider.max_value = Encoding.ENCODING_CONFIGS[newCodec].maxCRF
	max_quality_lbl.text = str(Encoding.ENCODING_CONFIGS[newCodec].maxCRF)

	quality_slider.value = Encoding.ENCODING_CONFIGS[newCodec].defaultCRF
	selected_quality_lbl.text = str(Encoding.ENCODING_CONFIGS[newCodec].defaultCRF) + " (default)"
