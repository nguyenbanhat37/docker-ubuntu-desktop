FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openbox \
    tigervnc-standalone-server \
    novnc \
    websockify \
    xterm \
    wget \
    curl \
    ca-certificates \
    netsurf-gtk \
    dbus-x11 \
    openssl \
    x11-xserver-utils \
    && rm -rf /var/lib/apt/lists/*

# VNC config
RUN mkdir -p /root/.vnc

RUN printf '#!/bin/sh\n\
xrdb $HOME/.Xresources\n\
openbox-session &\n\
netsurf-gtk &\n\
' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

# SSL
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes \
    -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080

CMD ["bash","-c","vncserver :1 -geometry 1024x768 -depth 16 && websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT:-6080} localhost:5901"]
