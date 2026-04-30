FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# ─── Install GUI + VNC + noVNC ─────────────────────────────
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-xserver-utils \
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

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
\n\
xrdb $HOME/.Xresources\n\
\n\
# start XFCE (full desktop giống Windows)\n\
startxfce4 &\n\
\n\
# fallback nếu XFCE lỗi\n\
xterm &\n\
\n\
' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

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
