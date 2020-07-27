FROM gitpod/workspace-full

USER gitpod

RUN sudo apt-get update && \
    sudo apt-get install -y \
        libssl-dev \
        libxcb-composite0-dev \
        pkg-config \
        libpython3.6 \
        rust-lldb

ENV RUST_LLDB=/usr/bin/lldb-8

RUN sudo apt-get install software-properties-common -y && \
    sudo apt-get install git libexif-dev liblzma-dev libz-dev libssl-dev \
        libgtk2.0-dev libice-dev libsm-dev libicu-dev libdrm-dev dh-autoreconf \
        autoconf automake build-essential libxml2-dev libass-dev libfreetype6-dev \
        libgpac-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev \
        libvorbis-dev libxcb1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-screensaver0-dev \
        libxcb-xfixes0-dev libxcb-keysyms1-dev libxcb-icccm4-dev libatspi2.0-dev \
        libxcb-render-util0-dev libxcb-util0-dev libxcb-xkb-dev libxrender-dev \
        libasound-dev libpulse-dev libxcb-sync0-dev libxcb-randr0-dev libegl1-mesa-dev \
        libx11-xcb-dev libffi-dev libncurses5-dev pkg-config texi2html bison yasm \
        zlib1g-dev xutils-dev python-xcbgen chrpath gperf -y --force-yes && \
    sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    sudo apt-get update && \
    sudo apt-get install gcc-8 g++-8 -y && \
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 && \
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 60 && \
    sudo update-alternatives --config gcc && \
    sudo add-apt-repository --remove ppa:ubuntu-toolchain-r/test -y

RUN sudo apt-get update && \
    sudo rm -rf /var/lib/apt/lists/*