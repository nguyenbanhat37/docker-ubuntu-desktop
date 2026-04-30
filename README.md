# docker-ubuntu-desktop
Ubuntu Desktop Web Browser Accessible Docker Image with Enhanced User Experience

## Features
✨ **Enhanced clipboard support** - Copy/paste between host and container works seamlessly  
🔊 **Audio support** - PulseAudio integration for sound  
🎨 **Improved UI** - Multiple icon themes, better display quality  
🔒 **Flexible user management** - Run as non-root user or root  
📦 **Lightweight & optimized** - Reduced image size with combined RUN commands  
🖥️ **Better display** - Higher DPI (96), improved resolution (1280x720)  
⌨️ **Clipboard manager** - XFCE4 Clipman pre-installed  
🚀 **Development tools** - htop, tmux, build-essential included
## 🌐 Cách truy cập (QUAN TRỌNG)

Sau khi deploy Railway:

👉 dùng URL:

https://your-app.up.railway.app/?resize=scale

✔ auto fit màn hình
✔ không bị scroll
✔ nhìn như desktop thật

## ScreenShot
![screenshot](screenshot.png)

## Usage
$ docker run -it --platform=linux/amd64 -p 6080:6080 akarita/docker-ubuntu-desktop

### With Audio Support
```bash
$ docker run -it --platform=linux/amd64 -p 6080:6080 \
    --device /dev/snd:/dev/snd \
    akarita/docker-ubuntu-desktop
```

### Advanced Usage (Non-root user)
```bash
$ docker run -it --platform=linux/amd64 -p 6080:6080 \
    -u user \
    akarita/docker-ubuntu-desktop
```

## Access
- **HTTP:** http://localhost:6080/vnc.html
- **HTTPS:** https://localhost:6080/vnc.html

Or open directly in browser:
- [Open VNC Web Interface (HTTP)](http://localhost:6080/vnc.html)
- [Open VNC Web Interface (HTTPS)](https://localhost:6080/vnc.html)

## Clipboard & Sharing
- **Copy from host to container:** Use Ctrl+C and paste with right-click menu in VNC
- **Clipboard Manager:** Right-click on desktop → Applications → Accessories → Clipman
- **Drag & Drop:** Limited support through browser - use clipboard as alternative

## DockerHub

https://hub.docker.com/r/akarita/docker-ubuntu-desktop

## Docker Pull
```bash
$ docker pull akarita/docker-ubuntu-desktop
```

## Docker Build
```bash
$ docker build . -t docker-ubuntu-desktop
```

## Improvements in Latest Version
- Optimized Dockerfile with fewer layers
- Added clipboard tools (xclip, xsel)
- Added clipboard manager (xfce4-clipman)
- Audio support (PulseAudio)
- Better display resolution and DPI settings
- Non-root user support
- Enhanced fonts and icon themes
- Better locale and timezone support
- Startup script for flexibility
- Development tools pre-installed

## License
MIT License (c) 2023 [Takahashi Akari](https://github.com/takahashi-akari)
