FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cần thiết
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    sudo xterm vim net-tools curl wget git tzdata \
    software-properties-common openssl \
    && rm -rf /var/lib/apt/lists/*

# Cài Firefox từ PPA mozilla
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' \
        > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' \
        > /etc/apt/apt.conf.d/51unattended-upgrades-firefox && \
    apt-get update -y && apt-get install -y firefox && \
    rm -rf /var/lib/apt/lists/*

# Cài icon theme
RUN apt-get update -y && apt-get install -y xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

# Tạo thư mục VNC
RUN mkdir -p /root/.vnc && touch /root/.Xauthority

# FIX CHÍNH: startxfce4 chạy foreground, KHÔNG dùng & để tránh exit sớm
RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\n\
xsetroot -solid grey\n\
exec /usr/bin/startxfce4\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Tạo SSL cert cho noVNC
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 \
    -nodes -out /root/self.pem -keyout /root/self.pem

EXPOSE 6080

# Railway inject biến $PORT tự động; fallback 6080 khi chạy local
CMD bash -c "\
    vncserver :1 \
        -localhost no \
        -SecurityTypes None \
        -geometry 1280x800 \
        -depth 24 \
        --I-KNOW-THIS-IS-INSECURE && \
    exec websockify \
        --web=/usr/share/novnc/ \
        --cert=/root/self.pem \
        --wrap-mode=ignore \
        ${PORT:-6080} localhost:5901"
