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

RUN apt update && apt install -y 
xfce4 
xfce4-terminal 
tigervnc-standalone-server 
novnc 
websockify 
dbus-x11 
x11-xserver-utils 
autocutsel 
firefox 
xclip 
&& apt clean

RUN mkdir -p /root/.vnc

RUN echo "#!/bin/bash\n
xrdb $HOME/.Xresources\n
autocutsel -fork\n
autocutsel -selection PRIMARY -fork\n
startxfce4 &" > /root/.vnc/xstartup && 
chmod +x /root/.vnc/xstartup

RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && 
chmod 600 /root/.vnc/passwd

RUN touch /root/.Xauthority

ENV PORT=6080
EXPOSE 6080

CMD bash -c "
vncserver :1 -geometry 1024x768 -depth 24 && 
websockify --web=/usr/share/novnc/ $PORT localhost:5901 
"
