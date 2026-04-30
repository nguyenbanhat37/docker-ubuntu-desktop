FROM --platform=linux/amd64 debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Cài các gói cần thiết
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    xfce4 xfce4-goodies xfce4-terminal \
    tigervnc-standalone-server \
    novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    sudo xterm vim net-tools curl wget git tzdata \
    openssl ca-certificates \
    libgtk-3-0 libdbus-glib-1-2 \
    openssh-server \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Cài Firefox từ Mozilla trực tiếp (không cần PPA)
RUN wget -q "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" \
        -O /tmp/firefox.tar.bz2 && \
    tar -xjf /tmp/firefox.tar.bz2 -C /opt/ && \
    ln -s /opt/firefox/firefox /usr/local/bin/firefox && \
    rm /tmp/firefox.tar.bz2

# ─── Cấu hình SSH ───────────────────────────────────────────
RUN mkdir -p /var/run/sshd

# Đặt mật khẩu root (đổi "your_password" thành mật khẩu bạn muốn)
RUN echo 'root:your_password' | chpasswd

# Cho phép root login qua SSH và dùng password
RUN sed -i \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' \
    -e 's/#Port 22/Port 22/' \
    /etc/ssh/sshd_config

# Tạo SSH host keys
RUN ssh-keygen -A

# ─── Cấu hình VNC ───────────────────────────────────────────
RUN mkdir -p /root/.vnc && touch /root/.Xauthority

RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources\n\
xsetroot -solid grey\n\
exec /usr/bin/startxfce4\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# SSL cert cho noVNC
RUN openssl req -new -subj "/C=VN/CN=novnc" -x509 -days 365 \
    -nodes -out /root/self.pem -keyout /root/self.pem

# ─── Ports ──────────────────────────────────────────────────
# Railway chỉ expose 1 port public ($PORT) → noVNC qua đó
# SSH tunnel qua noVNC port hoặc dùng Railway TCP nếu có plan trả phí
EXPOSE 6080
EXPOSE 22

# ─── Startup script ─────────────────────────────────────────
RUN printf '#!/bin/bash\n\
# Khởi động SSH\n\
service ssh start\n\
\n\
# Khởi động VNC\n\
vncserver :1 \\\n\
    -localhost no \\\n\
    -SecurityTypes None \\\n\
    -geometry 1280x800 \\\n\
    -depth 24 \\\n\
    --I-KNOW-THIS-IS-INSECURE\n\
\n\
# Khởi động noVNC websockify (giữ foreground)\n\
exec websockify \\\n\
    --web=/usr/share/novnc/ \\\n\
    --cert=/root/self.pem \\\n\
    --wrap-mode=ignore \\\n\
    ${PORT:-6080} localhost:5901\n' > /start.sh && chmod +x /start.sh

CMD ["/start.sh"]
