extends Control

@onready var thumbnail_panel: CenterContainer = $HSplitContainer/ThumbnailPanel
@onready var thumbnail_pic: TextureRect = $HSplitContainer/ThumbnailPanel/ThumbnailCenterPanel/ThumbnailPic
@onready var target_video_input: LineEdit = $HSplitContainer/LeftPanel/MarginContainer/SettingsContainer/TargetVideoInput
@onready var drop_file_hint_lbl: Label = $HSplitContainer/ThumbnailPanel/ThumbnailCenterPanel/DropFileHintWrapper/DropFileHintLbl
@onready var src_video_lbl: Label = $HSplitContainer/LeftPanel/MarginContainer/SettingsContainer/SrcVideoLbl

var inputVideoDirectory: String = ""
var inputVideoName: String = ""
var img = Image.new()

func generateThumbnail(srcPath):
	var output = []
	OS.execute("cmd.exe", ["/c", "ffmpeg -hide_banner -loglevel error -y -i \"%s\" -ss 3 -vframes 1 -c:v png %%TEMP%%\\EasyEncoder_thumbnail.png" % srcPath], output)

func loadThumbnail(srcPath):
	#ffmpeg -hide_banner -loglevel error -i D:\yt-dl\minecraft.mp4 -ss 00:00:3 -s 650x390 -vframes 1 -c:v png -f image2pipe -
	generateThumbnail(srcPath)
	var buf = FileAccess.get_file_as_bytes("%s/EasyEncoder_thumbnail.png" % OS.get_temp_dir())
	img.load_png_from_buffer(buf)
	thumbnail_pic.texture = ImageTexture.create_from_image(img)
	resizeThumbnailPic()

func _on_ready() -> void:
	get_window().close_requested.connect(Encoding.stopEncoding)
	get_tree().root.files_dropped.connect(func(files: PackedStringArray):
		loadThumbnail(files[0])

		var output_video_name = files[0].get_file().get_basename() + "_encoded.mp4"
		target_video_input.text = output_video_name
		drop_file_hint_lbl.visible = false

		inputVideoDirectory = files[0].get_base_dir() + '\\'
		inputVideoName = files[0].get_file()

		src_video_lbl.text = inputVideoName
	)


func _on_encode_btn_pressed() -> void:
	if Encoding.is_encoding:
		Encoding.stopEncoding()
	else:
		Encoding.startEncoding(inputVideoDirectory + inputVideoName, inputVideoDirectory + target_video_input.text)


func _on_thumbnail_panel_resized() -> void:
	resizeThumbnailPic()


func resizeThumbnailPic() -> void:
	if not thumbnail_pic or not thumbnail_pic.texture:
		return
	var imgRatio: float = float(thumbnail_pic.texture.get_size().x) / float(thumbnail_pic.texture.get_size().y)
	var imgPanelRatio: float = float(thumbnail_panel.size.x) / float(thumbnail_panel.size.y)
	print("imgRatio: %f, imgPanelRatio: %f" % [imgRatio, imgPanelRatio])
	if imgRatio > imgPanelRatio:
		thumbnail_pic.custom_minimum_size.x = thumbnail_panel.size.x
		thumbnail_pic.custom_minimum_size.y = thumbnail_panel.size.x / imgRatio
	else:
		thumbnail_pic.custom_minimum_size.y = thumbnail_panel.size.y
		thumbnail_pic.custom_minimum_size.x = thumbnail_panel.size.y * imgRatio
