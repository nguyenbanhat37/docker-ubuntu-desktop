FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y 
openbox tigervnc-standalone-server novnc websockify xterm 
wget curl ca-certificates netsurf-gtk dbus-x11 openssl 
x11-xserver-utils 
&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

RUN printf '#!/bin/sh\n
export DISPLAY=:1\n
unset SESSION_MANAGER\n
unset DBUS_SESSION_BUS_ADDRESS\n
\n\

# tránh crash nếu xrdb lỗi\n\

if command -v xrdb >/dev/null 2>&1; then xrdb $HOME/.Xresources; fi\n
\n
xsetroot -solid grey\n
\n\

# giữ session sống (QUAN TRỌNG)\n\

exec openbox-session\n' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

RUN mkdir -p /root/.config/openbox && echo "netsurf-gtk &" > /root/.config/openbox/autostart

RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080

CMD ["bash","-c","vncserver :1 -geometry 1024x768 -depth 16 && websockify --web=/usr/share/novnc/ --cert=/root/self.pem ${PORT:-6080} localhost:5901"]
