FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Cài đặt các gói cần thiết
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    dbus-x11 \
    x11-xserver-utils \
    autocutsel \
    firefox \
    xclip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Tạo thư mục VNC
RUN mkdir -p /root/.vnc

# Tạo xstartup script đúng cú pháp (lỗi gốc: viết sai newline)
RUN printf '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
autocutsel -fork\n\
autocutsel -selection PRIMARY -fork\n\
startxfce4 &\n' > /root/.vnc/xstartup && chmod +x /root/.vnc/xstartup

# Đặt mật khẩu VNC
RUN echo "123456" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Tạo file Xauthority
RUN touch /root/.Xauthority

# Lỗi gốc: ENV và EXPOSE không thể gộp chung một dòng
ENV PORT=6080
EXPOSE 6080

# Script khởi động với xử lý lỗi tốt hơn
CMD bash -c "\
    vncserver :1 -geometry 1280x800 -depth 24 -localhost no && \
    websockify --web=/usr/share/novnc/ --wrap-mode=ignore $PORT localhost:5901"
