FROM quay.io/fedora/fedora:45

WORKDIR /workspace

# System packages
RUN dnf upgrade -y --refresh && \
  dnf install -y \
    bind-utils \
    jq \
    bc \
    unzip \
    wget \
    nodejs24 \
    npm \
    pnpm \
    golang \
    python3 \
    python3-pip \
    make \
    cmake

# User setup
RUN useradd -m -s /bin/bash -G wheel dev && \
    echo 'dev:dev' | chpasswd && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p /etc/skel.dev && \
    echo -e "root:1:65535\ndev:1:999\ndev:1001:64535" > /etc/subuid && \
    echo -e "root:1:65535\ndev:1:999\ndev:1001:64535" > /etc/subgid

# User environment
USER dev

ENV HOME=/home/dev \
    NPM_CONFIG_PREFIX=/home/dev/.npm-global \
    GOPATH=/home/dev/.go \
    PATH=$PATH:/home/dev/.npm-global/bin:/home/dev/.go/bin

ENTRYPOINT ["bash"]