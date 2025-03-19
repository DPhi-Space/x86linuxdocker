# Container for running Vivado on M1/M2 macs
# though it should work equally on Intel macs
FROM --platform=linux/amd64 ubuntu:22.04

# Update system and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Fix frontend issues for apt installations
ARG DEBIAN_FRONTEND=noninteractive

# Install ca-certificates
RUN apt -y install ca-certificates

# Update system and upgrade packages
RUN apt-get update && apt-get upgrade -y --fix-missing

# Ensure repositories are up to date before installing dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    dbus dbus-x11 x11-utils xorg alsa-utils mesa-utils net-tools \
    libgl1-mesa-dri gtk2-engines lxappearance fonts-droid-fallback sudo \
    ubuntu-gnome-default-settings curl gnupg lxde arc-theme \
    gtk2-engines-murrine gtk2-engines-pixbuf gnome-themes-standard nano xterm \
    vim  # Install Vim

# Add Mozilla Team PPA and install Firefox without Snap
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:mozillateam/ppa && \
    echo 'Package: firefox*' | tee /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin: release o=LP-PPA-mozillateam' | tee -a /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin-Priority: 501' | tee -a /etc/apt/preferences.d/mozilla-firefox \
    && apt-get update && apt-get install -y --no-install-recommends firefox

# Install dependencies for Vivado
RUN apt-get install -y --no-install-recommends \
    python3-pip python3-dev build-essential git gcc-multilib g++ \
    ocl-icd-opencl-dev libjpeg62-dev libc6-dev-i386 graphviz make \
    unzip libtinfo5 xvfb libncursesw5 locales libswt-gtk-4-jni

# Install VNC Server
RUN apt-get install -y tigervnc-standalone-server tigervnc-xorg-extension

# Install Java (OpenJDK 11)
RUN apt-get install -y openjdk-11-jdk

# Create user "user" with password "password"
RUN useradd --create-home --shell /bin/bash --user-group --groups adm,sudo user
RUN sh -c 'echo "user:password" | chpasswd'
RUN chown -R user:user /home/user

# Setup LXDE
RUN mkdir -p /home/user/.config/pcmanfm/LXDE/
RUN ln -sf /usr/local/share/doro-lxde-wallpapers/desktop-items-0.conf /home/user/.config/pcmanfm/LXDE/
RUN mv /usr/bin/lxpolkit /usr/bin/lxpolkit.bak

# Setup TigerVNC
RUN sed -i 's/-iconic/-nowin/g' /etc/X11/Xtigervnc-session
RUN mkdir /home/user/.vnc
RUN echo "password" | vncpasswd -f > /vncpasswd
RUN chown user /vncpasswd
RUN chmod 600 /vncpasswd

# Set the locale (Vivado requirement)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Without this, Vivado will crash when synthesizing
ENV LD_PRELOAD="/lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libselinux.so.1 /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0"

# Download and extract the Virtual Satellite software
#WORKDIR /home/user
RUN curl -L -o VirtualSatellite.tar.gz \
    https://github.com/virtualsatellite/VirtualSatellite4-Core/releases/download/Release_4.18.0/VirSat_Core_Release_4.18.0_565adc560ae31814295f033298f6ae8748feeb27-linux.gtk.x86_64.tar.gz && \
    tar -xzf VirtualSatellite.tar.gz

RUN rm VirtualSatellite.tar.gz

WORKDIR /home/user



# Change ownership of extracted files to user
#RUN chown -R user:user /home/user/VirSat_Core_Release_4.18.0_565adc560ae31814295f033298f6ae8748feeb27-linux.gtk.x86_64

# Switch to user
#USER user
#WORKDIR /home/user

# Default command
#CMD ["/bin/bash"]
