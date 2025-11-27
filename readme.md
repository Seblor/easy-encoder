# Easy Encoder

Easy Encoder is a simple, user-friendly front‑end built with the Godot Engine that lets you encode media files without dealing with complex command‑line options.

> Note: This project is my first Godot app, created as a learning exercise. While it works well for basic encoding tasks, it may lack advanced features found in dedicated tools.

---

## Features

- Clean, minimal UI built in Godot
- Adjustable encoding **quality** via slider
- **Mute / unmute** audio toggle
- Preset **encoding options** handled in one place

---

## Screenshots

<p align="center">
  <img src="imgs/img1.png" alt="Easy Encoder main window" width="400" />
  <img src="imgs/img2.png" alt="Easy Encoder encoding in progress" width="400" />
</p>

---

## Requirements

- **Godot Engine** 4.x (open `project.godot`)
- A working video/audio encoder installed on your system (for example `ffmpeg`) if your scripts are wired to call external tools
- Windows 10/11 for the provided `.exe` build

> If you just want to use the app, you only need the Windows requirements. To modify the project, install Godot as well.

---

## Getting Started

### Running the Editor Version

1. Install Godot 4.x.
2. Clone or download this repository.
3. Open `project.godot` in Godot.
4. Run the project (F5 or ▶ in the Godot editor).

The main scene is `main.tscn`, with the main script in `main.gd`. Supporting scripts live under `src/`.

### Using the Windows Build

1. Head over to [the latest build page](https://github.com/Seblor/easy-encoder/releases/latest).
2. Download `Easy Encoder.exe` and place it in a convenient location.
3. Download ffmpeg from [ffmpeg.org](https://ffmpeg.org/download.html) (or directly download it [here](https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n8.0-latest-win64-gpl-8.0.zip)) and ensure it's accessible via your system PATH (alternatively you can place `ffmpeg.exe` and `ffprobe.exe` next to `Easy Encoder.exe`).
4. You're ready to run the application!
