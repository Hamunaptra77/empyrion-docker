FROM ubuntu:focal

# Umgebungsvariablen
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# System vorbereiten
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        curl \
        tar \
        unzip \
        xz-utils \
        gnupg2 \
        software-properties-common \
        xvfb \
        net-tools \
        libc6:i386 \
        locales \
        ca-certificates \
        libgl1-mesa-glx:i386 \
        libgl1-mesa-dri:i386 \
        libxrandr2:i386 \
        libxinerama1:i386 \
        libxcomposite1:i386 \
        libxcursor1:i386 \
        libxi6:i386 \
        libdbus-1-3:i386 \
        libnss3:i386 \
        libxss1:i386 \
        libgtk-3-0:i386 \
        winbind \
        cabextract \
        p7zip-full \
        wget && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# WineHQ installieren (Version 5.7)
RUN curl -s https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get update && \
    apt-get install -y \
        wine-staging=5.7~focal \
        wine-staging-i386=5.7~focal \
        wine-staging-amd64=5.7~focal \
        winetricks && \
    rm -rf /var/lib/apt/lists/*

# Nutzer anlegen
RUN useradd -m user

USER user
ENV HOME=/home/user
WORKDIR $HOME

# SteamCMD herunterladen und entpacken
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxv

# Verzeichnisstruktur vorbereiten
RUN mkdir -p $HOME/Steam

# Root: X11 Socket vorbereiten
USER root
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Ports für Empyrion Server
EXPOSE 30000/udp
EXPOSE 30001/udp
EXPOSE 30002/udp
EXPOSE 30003/udp
EXPOSE 30004/udp

# VOLUMES für Spielstand & Konfiguration
VOLUME /home/user/Steam

# Konfiguration & Szenarien
#COPY config/ /config/
#COPY scenario/ /scenarios/

# Entrypoint-Skript
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
