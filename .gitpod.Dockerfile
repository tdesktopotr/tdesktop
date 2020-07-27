FROM buildpack-deps:cosmic

### base ###
RUN yes | unminimize \
    && apt-get install -y \
        asciidoctor \
        bash-completion \
        build-essential \
        htop \
        jq \
        less \
        llvm \
        locales \
        man-db \
        nano \
        software-properties-common \
        sudo \
        vim \
    && locale-gen en_US.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*
ENV LANG=en_US.UTF-8

RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
    && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/ALL ALL=NOPASSWD:ALL/g' /etc/sudoers \
    && usermod -aG sudo gitpod
ENV HOME=/home/gitpod
WORKDIR $HOME
# custom Bash prompt
RUN { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> .bashrc

### Python ###
ENV PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && { echo; \
        echo 'eval "$(pyenv init -)"'; \
        echo 'eval "$(pyenv virtualenv-init -)"'; } >> .bashrc \
    && pyenv install 3.6.6 \
    && pyenv global 3.6.6 \
    && pip install virtualenv pipenv python-language-server[all]==0.19.0 \
    && rm -rf /tmp/*

RUN sudo echo "----------- STEP WITH C++  ----------"

RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
    && apt-add-repository -yu "deb http://apt.llvm.org/cosmic/ llvm-toolchain-cosmic-6.0 main" \
    && apt-get install -y \
        clang-format-6.0 \
        clang-tools-6.0 \
        cmake \
    && apt-get update -y \
    && ln -s /usr/bin/clangd-6.0 /usr/bin/clangd \
    && apt-get install -y \
        software-properties-common \
        git \
        libexif-dev \
        liblzma-dev \
        libz-dev \
        libssl-dev \
        libgtk2.0-dev \
        libice-dev \
        libsm-dev \
        libicu-dev \
        libdrm-dev \
        dh-autoreconf \
        autoconf \
        automake \
        build-essential \
        libxml2-dev \
        libass-dev \
        libfreetype6-dev \
        libgpac-dev \
        libsdl1.2-dev \
        libtheora-dev \
        libtool \
        libva-dev \
        libvdpau-dev \
        libvorbis-dev \
        libxcb1-dev \
        libxcb-image0-dev \
        libxcb-shm0-dev \
        libxcb-screensaver0-dev \
        libxcb-xfixes0-dev \
        libxcb-keysyms1-dev \
        libxcb-icccm4-dev \
        libatspi2.0-dev \
        libxcb-render-util0-dev \
        libxcb-util0-dev \
        libxcb-xkb-dev \
        libxrender-dev \
        libasound-dev \
        libpulse-dev \
        libxcb-sync0-dev \
        libxcb-randr0-dev \
        libegl1-mesa-dev \
        libx11-xcb-dev \
        libffi-dev \
        libncurses5-dev \
        pkg-config \
        texi2html \
        bison \
        yasm \
        zlib1g-dev \
        xutils-dev \
        chrpath \
        gperf \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

RUN sudo echo "----------- STEP WITH C++ ---------- DONE ----------"

RUN sudo echo "----------- STEP WITH RUST LLDB  ----------"

RUN sudo apt-get update && \
    sudo apt-get install -y \
        libssl-dev \
        libxcb-composite0-dev \
        pkg-config \
        libpython3.6 \
        rust-lldb

ENV RUST_LLDB=/usr/bin/lldb-8
RUN sudo echo "----------- STEP WITH RUST LLDB ---------- DONE ----------"

RUN sudo echo "----------- STEP WITH NODE  ----------"

ARG NODE_VERSION=8.14.0
ENV PATH=/home/gitpod/.nvm/versions/node/v8.14.0/bin:$PATH
RUN curl -fsSL https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
    && bash -c ". .nvm/nvm.sh \
        && npm config set python /usr/bin/python --global \
        && npm config set python /usr/bin/python \
        && npm install -g typescript"

RUN sudo echo "----------- STEP WITH NODE ---------- DONE ----------"

### checks ###
USER gitpod
RUN sudo echo "Running 'sudo' for Gitpod: success"

# no root-owned files in the home directory
RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
    && { [ -z "$notOwnedFile" ] \
        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }

RUN sudo echo "----------- STEP WITH GCC  ----------"

RUN sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    sudo apt-get update && \
    sudo apt-get install gcc-8 g++-8 -y && \
    sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 && \
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 60 && \
    sudo update-alternatives --config gcc && \
    sudo add-apt-repository --remove ppa:ubuntu-toolchain-r/test -y

RUN sudo echo "----------- STEP WITH GCC ---------- DONE ----------"

RUN sudo echo "----------- LAST APT-GET UPDATE  ----------"

RUN sudo apt-get update && \
    sudo rm -rf /var/lib/apt/lists/*

RUN sudo echo "----------- LAST APT-GET UPDATE ---------- DONE ----------"