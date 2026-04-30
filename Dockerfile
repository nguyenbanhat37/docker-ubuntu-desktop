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

# ─── Install ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server \
    novnc websockify \
    dbus dbus-x11 \
    x11-xserver-utils \
    xterm wget curl \
    ca-certificates \
    firefox-esr \
    pcmanfm tint2 \
    openssh-server \
    net-tools openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ─── bore tunnel ───────────────────────────────────────────
RUN curl -L --retry 5 --retry-delay 2 \
    https://github.com/ekzhang/bore/releases/download/v0.4.0/bore-linux-amd64 \
    -o /usr/local/bin/bore && chmod +x /usr/local/bin/bore
    
# ─── SSH config ───────────────────────────────────────────
RUN mkdir -p /var/run/sshd

RUN echo 'root:123456' | chpasswd

RUN sed -i \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' \
    /etc/ssh/sshd_config

RUN ssh-keygen -A

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

# ─── SSL ──────────────────────────────────────────────────
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes \
    -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080 22

# ─── START ────────────────────────────────────────────────
CMD ["bash","-c","\ 
service ssh start && \ 
vncserver :1 -geometry 1280x720 -depth 24 -localhost no && \ 
bore local 22 --to bore.pub & \ 
websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT:-6080} localhost:5901 \
"]
