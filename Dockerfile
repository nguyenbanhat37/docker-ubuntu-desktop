FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    PORT=6080

RUN apt-get update -y && apt-get install --no-install-recommends -y \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server novnc websockify \
    sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common \
    openssl ca-certificates gnupg dirmngr \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:mozillateam/ppa -y \
    && echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' > /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
    && apt-get update -y && apt-get install -y firefox xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc \
    && touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD ["bash", "-lc", "set -e; vncserver -kill :1 >/dev/null 2>&1 || true; rm -f /tmp/.X1-lock /tmp/.X11-unix/X1; vncserver :1 -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE; if [ ! -f /root/.vnc/self.pem ]; then openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out /root/.vnc/self.pem -keyout /root/.vnc/self.pem; fi; exec websockify --web=/usr/share/novnc/ --cert=/root/.vnc/self.pem ${PORT} localhost:5901"]
