FROM ubuntu:focal

# System Update
RUN export DEBIAN_FRONTEND noninteractive && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y net-tools tar unzip curl xz-utils gnupg2 software-properties-common xvfb libc6:i386 locales && \
    echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen && \
    curl -s https://dl.winehq.org/wine-builds/winehq.key | apt-key add - && \
    apt-add-repository -y 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' && \
    apt-get install -y wine-staging=5.7~focal wine-staging-i386=5.7~focal wine-staging-amd64=5.7~focal winetricks && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s '/home/user/Steam/steamapps/common/Empyrion - Dedicated Server/' /server && \
    useradd -m user

USER user
ENV HOME /home/user
WORKDIR /home/user
VOLUME /home/user/Steam

# SteamCMD Download
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar xz

# SteamCMD Installation
RUN ./steamcmd.sh +login anonymous +quit || :
USER root
RUN mkdir /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Docker Ports
EXPOSE 30000/udp
EXPOSE 30001/udp
EXPOSE 30002/udp
EXPOSE 30003/udp
EXPOSE 30004/udp

# EmpyrionServer Installation
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]