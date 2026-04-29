FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y xfce4 xfce4-terminal tigervnc-standalone-server novnc websockify dbus-x11 x11-xserver-utils autocutsel firefox xclip && apt clean

RUN mkdir -p /root/.vnc

RUN echo '#!/bin/bash
xrdb $HOME/.Xresources
autocutsel -fork
autocutsel -selection PRIMARY -fork
startxfce4 &' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

ENV PORT=6080
EXPOSE 6080

CMD bash -c "vncserver :1 -geometry 1024x768 -depth 24 && websockify --web=/usr/share/novnc/ $PORT localhost:5901"
