FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# ─── Install GUI + VNC + noVNC ─────────────────────────────
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    novnc websockify \
    dbus dbus-x11 \
    x11-xserver-utils \
    xterm wget curl \
    ca-certificates \
    firefox-esr \
    pcmanfm \
    tint2 \
    net-tools \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# ─── VNC config ───────────────────────────────────────────
RUN mkdir -p /root/.vnc

# ✔ FIX: xstartup chuẩn (KHÔNG crash XFCE)
RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
\n\
# Fix runtime cho XFCE\n\
export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
mkdir -p $XDG_RUNTIME_DIR\n\
chmod 700 $XDG_RUNTIME_DIR\n\
\n\
# tránh lỗi xrdb\n\
[ -f $HOME/.Xresources ] && xrdb $HOME/.Xresources\n\
\n\
# start XFCE đúng cách (GIỮ SESSION)\n\
exec dbus-launch --exit-with-session startxfce4\n\
' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# password VNC
RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

# ─── SSL cho noVNC ────────────────────────────────────────
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes \
    -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080

# ─── START ────────────────────────────────────────────────
CMD ["bash","-c","\
vncserver :1 -geometry 1280x720 -depth 24 && \
websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT} localhost:5901\
"]
