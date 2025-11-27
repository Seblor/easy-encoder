extends Node

enum Codecs {
	H264,
	H265,
	AV1
}

const ENCODING_CONFIGS: Dictionary = {
	Codecs.H264: {
		minCRF = 0,
		maxCRF = 51,
		defaultCRF = 23
	},
	Codecs.H265: {
		minCRF = 0,
		maxCRF = 51,
		defaultCRF = 28
	},
	Codecs.AV1: {
		minCRF = 0,
		maxCRF = 63,
		defaultCRF = 35
	}
}

var is_encoding: bool = false

# Temp file path (logical, Godot-style)
var _progress_file_path: String = "user://ffmpeg_progress.txt"
var _progress_timer: Timer
var _ffmpeg_pid: int = -1

# Tracking for true percentage
var _total_duration_sec: float = 0.0
var _last_out_time_ms: int = 0

func _ready() -> void:
	# Create a timer to poll the ffmpeg progress file
	_progress_timer = Timer.new()
	_progress_timer.wait_time = 0.5
	_progress_timer.one_shot = false
	_progress_timer.autostart = false
	_progress_timer.timeout.connect(_poll_ffmpeg_progress)
	add_child(_progress_timer)

func selectCodec(newCodec: Codecs) -> void:
	if (selectedCodec != newCodec):
		selectedCRF = ENCODING_CONFIGS[newCodec].defaultCRF
	selectedCodec = newCodec

# Use ffprobe to get media duration in seconds
func _get_media_duration_seconds(path: String) -> float:
	var cmd := "ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"%s\"" % path
	var output: Array = []
	var exit_code := OS.execute("cmd", ["/C", cmd], output, true)
	if exit_code != 0 or output.size() == 0:
		return 0.0
	var txt := String(output[0]).strip_edges()
	var val := txt.to_float()
	if val <= 0.0:
		return 0.0
	return val

func stopEncoding() -> void:
	if is_encoding and _ffmpeg_pid != -1:
		OS.kill(_ffmpeg_pid)
		_ffmpeg_pid = -1
		_progress_timer.stop()
		_update_progress(0)
		is_encoding = false
		var btn = get_tree().get_root().get_node("Root").find_child("EncodeBtn")
		if btn:
			btn.text = "\nEncode\n\n"
		if FileAccess.file_exists(_progress_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_progress_file_path))

func startEncoding(srcPath: String, targetPath: String) -> void:
	# Reset duration/progress tracking
	_total_duration_sec = _get_media_duration_seconds(srcPath)
	_last_out_time_ms = 0

	var codecStr = ""
	match selectedCodec:
		Codecs.H264:
			codecStr = "libx264"
		Codecs.H265:
			codecStr = "libx265"
		Codecs.AV1:
			codecStr = "libaom-av1"
	
	# Resolve user:// to a real OS path for ffmpeg
	var progress_os_path := ProjectSettings.globalize_path(_progress_file_path)

	# Remove previous progress file if it exists
	if FileAccess.file_exists(_progress_file_path):
		DirAccess.remove_absolute(progress_os_path)

	# Build ffmpeg arguments instead of using cmd string
	var args: Array = [
		"-hide_banner",
		"-loglevel", "error",
		"-y",
		"-i", srcPath,
		"-c:v", codecStr,
		"-crf", str(selectedCRF),
	]

	if mute:
		args.append("-an")

	args.append_array([
		"-progress", progress_os_path,
		"-nostats",
		targetPath,
	])

	# Run ffmpeg directly as a detached process so the game does not block
	_ffmpeg_pid = OS.create_process("ffmpeg", args)
	
	# Start polling the progress file
	_update_progress(0)
	_progress_timer.start()
	is_encoding = true
	var btn = get_tree().get_root().get_node("Root").find_child("EncodeBtn")
	if btn:
		btn.text = "\nStop Encoding\n\n"

func _poll_ffmpeg_progress() -> void:
	if not FileAccess.file_exists(_progress_file_path):
		return
	
	var f := FileAccess.open(_progress_file_path, FileAccess.READ)
	if f == null:
		return
	
	var last_progress: String = ""
	var last_out_time_ms: int = _last_out_time_ms
	while not f.eof_reached():
		var line: String = f.get_line().strip_edges()
		if line.begins_with("out_time_ms="):
			var val_str := line.substr("out_time_ms=".length())
			var ms := int(val_str.to_int())
			if ms > 0:
				last_out_time_ms = ms
		elif line.begins_with("progress="):
			last_progress = line.substr("progress=".length())
	f.close()
	
	_last_out_time_ms = last_out_time_ms
	
	if last_progress == "":
		return
	
	if last_progress == "continue":
		if _total_duration_sec > 0.0 and last_out_time_ms > 0:
			var current_sec := float(last_out_time_ms) / 1000000.0
			var pct: float = clamp(100.0 * current_sec / _total_duration_sec, 0.0, 99.0)
			_update_progress(pct)
		else:
			# Fallback: indeterminate bump if we don't know duration
			var bar = get_tree().get_root().get_node("Root").find_child("ProgressBar")
			if bar:
				bar.value = min(bar.value + 1.0, 99.0)
	elif last_progress == "end":
		_progress_timer.stop()
		_update_progress(100)
		is_encoding = false
		var btn = get_tree().get_root().get_node("Root").find_child("EncodeBtn")
		if btn:
			btn.text = "\nEncode\n\n"
		if FileAccess.file_exists(_progress_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_progress_file_path))

func _update_progress(newValue: float) -> void:
	var bar = get_tree().get_root().get_node("Root").find_child("ProgressBar")
	if bar:
		bar.value = newValue

@export var selectedCodec: Codecs = Codecs.H265
@export var selectedCRF: int = ENCODING_CONFIGS[Codecs.H265].defaultCRF

@export var mute: bool = false
