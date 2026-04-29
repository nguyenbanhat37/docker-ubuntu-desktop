FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Tokyo

# Install system dependencies with layer optimization
RUN apt update -y && apt install --no-install-recommends -y \
    # Desktop environment
    xfce4 xfce4-goodies xfce4-clipman xfce4-panel-profiles \
    # VNC & Web interface
    tigervnc-standalone-server websockify novnc \
    # Display & clipboard support
    dbus-x11 x11-utils x11-xserver-utils x11-apps xclip xsel \
    # Audio support
    pulseaudio pulseaudio-utils pavucontrol \
    # Essential tools
    sudo xterm init systemd vim nano net-tools curl wget git \
    tzdata locales ca-certificates openssl gnupg dirmngr \
    # Development tools
    build-essential htop tmux less \
    # UI enhancements
    xubuntu-icon-theme papirus-icon-theme \
    # Browser dependencies
    software-properties-common fonts-dejavu fonts-liberation fonts-noto \
    && locale-gen en_US.UTF-8 \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Firefox from Mozilla PPA
RUN add-apt-repository ppa:mozillateam/ppa -y \
    && echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox \
    && apt update -y && apt install -y firefox \
    && apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup user (recommended instead of always using root)
RUN useradd -m -s /bin/bash -G sudo,audio,video user \
    && echo 'user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user

# Setup root environment
RUN mkdir -p /root/.Xauthority /root/.cache /root/.vnc \
    && chmod 700 /root/.vnc \
    && touch /root/.Xauthority

# Create startup script for better flexibility
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Generate SSL certificate if not exists
if [ ! -f /root/.vnc/self.pem ]; then
    openssl req -new -x509 -days 365 -nodes \
        -out /root/.vnc/self.pem \
        -keyout /root/.vnc/self.pem \
        -subj "/C=JP/ST=Tokyo/L=Tokyo/O=VNC/CN=vnc"
fi

# Start VNC server with improved settings
vncserver \
    -localhost no \
    -SecurityTypes None \
    -geometry 1280x720 \
    -depth 24 \
    -dpi 96 \
    --I-KNOW-THIS-IS-INSECURE

# Start WebSockify proxy with SSL
websockify -D \
    --web=/usr/share/novnc/ \
    --cert=/root/.vnc/self.pem \
    --no-auth \
    6080 localhost:5901

# Keep container running
echo "VNC Server running on port 5901"
echo "Access at: https://localhost:6080/vnc.html"
tail -f /dev/null
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 5901
EXPOSE 6080

ENTRYPOINT ["/entrypoint.sh"]
