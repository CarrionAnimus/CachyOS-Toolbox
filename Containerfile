FROM archlinux:base-devel AS rootfs

RUN  pacman -Syu --noconfirm && \
     pacman -S --needed --noconfirm pacman-contrib git openssh sudo curl wget
RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman.conf -o /etc/pacman.conf
RUN  curl https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/cachyos-mirrorlist/cachyos-mirrorlist -o /etc/pacman.d/cachyos-mirrorlist


## include to pacman own keyring to install signed packages
RUN  pacman-key --init && \
     pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && \
     pacman-key --lsign-key F3B607488DB35A47 && \
     pacman -Sy && \
	 pacman -S --needed --noconfirm cachyos-keyring cachyos-mirrorlist cachyos-v3-mirrorlist cachyos-v4-mirrorlist cachyos-hooks && \
	 pacman -Syu --noconfirm && \
     rm -rf /var/lib/pacman/sync/* && \
     find /var/cache/pacman/ -type f -delete

RUN curl https://raw.githubusercontent.com/CachyOS/docker/master/pacman-v3.conf -o /etc/pacman.conf
RUN pacman -Syu --noconfirm && \
    rm -rf /var/lib/pacman/sync/* && \
    find /var/cache/pacman/ -type f -delete

# Install packages Distrobox adds automatically, this speeds up first launch
RUN pacman -S \
        adw-gtk-theme \
        bash-completion \
        bc \
        curl \
        diffutils \
        findutils \
        glibc \
        gnupg \
        inetutils \
        keyutils \
        less \
        lsof \
        man-db \
        man-pages \
        mlocate \
        mtr \
        ncurses \
        nss-mdns \
        openssh \
        pigz \
        pinentry \
        procps-ng \
        rsync \
        shadow \
        sudo \
        tcpdump \
        time \
        traceroute \
        tree \
        tzdata \
        unzip \
        util-linux \
        util-linux-libs \
        vte-common \
        wget \
        words \
        xorg-xauth \
        zip \
        mesa \
        opengl-driver \
        vulkan-intel \
        vte-common \
        vulkan-radeon \
        paru \
        --noconfirm && \
    && find /var/cache/pacman/ -type f -delete

# Distrobox Integration
RUN git clone https://github.com/89luca89/distrobox.git --single-branch /tmp/distrobox && \
    cp /tmp/distrobox/distrobox-host-exec /usr/bin/distrobox-host-exec && \
    ln -s /usr/bin/distrobox-host-exec /usr/bin/flatpak && \
    wget https://github.com/1player/host-spawn/releases/download/$(cat /tmp/distrobox/distrobox-host-exec | grep host_spawn_version= | cut -d "\"" -f 2)/host-spawn-$(uname -m) -O /usr/bin/host-spawn && \
    chmod +x /usr/bin/host-spawn && \
    rm -drf /tmp/distrobox

FROM scratch
LABEL org.opencontainers.image.description="CachyOS - Arch-based distribution offering an easy installation, several customizations, and unique performance optimization."
COPY --from=rootfs / /
CMD ["/usr/bin/bash"]
