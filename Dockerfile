# FROM --platform=linux/amd64 ubuntu:22.04

# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt update -y && apt install --no-install-recommends -y xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify sudo xterm init systemd snapd vim net-tools curl wget git tzdata
# RUN apt update -y && apt install -y dbus-x11 x11-utils x11-xserver-utils x11-apps
# RUN apt install software-properties-common -y
# RUN add-apt-repository ppa:mozillateam/ppa -y
# RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
# RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
# RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
# RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
# RUN apt update -y && apt install -y firefox
# RUN apt update -y && apt install -y xubuntu-icon-theme
# RUN touch /root/.Xauthority
# EXPOSE 5901
# EXPOSE 6080
# CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null"

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài tối thiểu để chạy GUI nhẹ

RUN apt update && apt install -y 
xfce4 xfce4-terminal 
tigervnc-standalone-server 
novnc websockify 
dbus-x11 x11-xserver-utils 
firefox 
curl 
&& apt clean

# Setup VNC

RUN mkdir -p /root/.vnc

# XFCE startup

RUN echo "#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &" > /root/.vnc/xstartup && 
chmod +x /root/.vnc/xstartup

# Tạo password VNC (123456)

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && 
chmod 600 /root/.vnc/passwd

# Fix Xauthority

RUN touch /root/.Xauthority

# Railway dùng PORT env

ENV PORT=6080
EXPOSE 6080

# Start VNC + noVNC

CMD bash -c "
vncserver :1 -geometry 1024x768 -depth 24 && 
websockify --web=/usr/share/novnc/ $PORT localhost:5901 
"
