# FROM debian:bookworm-slim

# ENV DEBIAN_FRONTEND=noninteractive

# # ─── Install GUI + VNC + noVNC ─────────────────────────────
# RUN apt-get update && apt-get install -y \
#     xfce4 xfce4-goodies \
#     xfce4-power-manager \
#     tigervnc-standalone-server \
#     novnc websockify \
#     dbus dbus-x11 \
#     x11-xserver-utils \
#     xterm wget curl \
#     ca-certificates \
#     firefox-esr \
#     pcmanfm \
#     tint2 \
#     net-tools \
#     openssl \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # ─── VNC config ───────────────────────────────────────────
# RUN mkdir -p /root/.vnc

# # ✔ xstartup FIX FULL
# RUN printf '#!/bin/sh\n\
# unset SESSION_MANAGER\n\
# unset DBUS_SESSION_BUS_ADDRESS\n\
# \n\
# export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
# mkdir -p $XDG_RUNTIME_DIR\n\
# chmod 700 $XDG_RUNTIME_DIR\n\
# \n\
# # fix xrdb\n\
# [ -f $HOME/.Xresources ] && xrdb $HOME/.Xresources || true\n\
# \n\
# # kill power manager (fix crash)\n\
# pkill xfce4-power-manager 2>/dev/null || true\n\
# \n\
# # disable compositor (nhẹ hơn)\n\
# xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true\n\
# \n\
# # start XFCE stable\n\
# exec dbus-launch --exit-with-session startxfce4\n\
# ' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# # password VNC
# RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# RUN touch /root/.Xauthority

# # ─── SSL ──────────────────────────────────────────────────
# RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes \
#     -out /root/self.pem -keyout /root/self.pem

# EXPOSE 6080

# # ─── START (FIX 502 + giữ process sống) ───────────────────
# CMD ["bash","-c","\ 
# vncserver :1 -geometry 1280x720 -depth 24 -localhost no && \ 
# websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT:-6080} localhost:5901 \
# "]





FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# ─── Install GUI + VNC + ttyd ─────────────────────────────
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    novnc websockify \
    dbus dbus-x11 \
    x11-xserver-utils \
    xterm wget curl \
    ca-certificates \
    pcmanfm tint2 \
    net-tools openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ─── Cài ttyd (terminal web) ──────────────────────────────
RUN wget -O /usr/local/bin/ttyd \
    https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 && \
    chmod +x /usr/local/bin/ttyd

# ─── VNC config ───────────────────────────────────────────
RUN mkdir -p /root/.vnc

RUN printf '#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
\n\
export XDG_RUNTIME_DIR=/tmp/runtime-root\n\
mkdir -p $XDG_RUNTIME_DIR\n\
chmod 700 $XDG_RUNTIME_DIR\n\
\n\
[ -f $HOME/.Xresources ] && xrdb $HOME/.Xresources || true\n\
\n\
pkill xfce4-power-manager 2>/dev/null || true\n\
xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true\n\
\n\
exec dbus-launch --exit-with-session startxfce4\n\
' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd
RUN touch /root/.Xauthority

# ─── SSL cho noVNC ────────────────────────────────────────
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes \
    -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080 7681

# ─── START ────────────────────────────────────────────────
CMD ["bash","-c","\
vncserver :1 -geometry 1280x720 -depth 24 -localhost no && \
ttyd -p 7681 -W bash & \
websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT:-6080} localhost:5901 \
"]
