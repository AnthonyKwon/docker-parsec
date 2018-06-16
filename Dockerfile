FROM phusion/baseimage:0.10.1

# use the init system
CMD ["/sbin/my_init"]

# parsec dependencies + sound + gpu (install_clean is a wrapper around apt-get)
RUN install_clean libcairo2 libfreetype6 libgdk-pixbuf2.0-0 libgl1-mesa-glx libgl1 libglib2.0-0 libgtk2.0-0 \ 
    libpango-1.0-0 libpangocairo-1.0-0 libsm6 libxxf86vm1 pulseaudio-utils libgl1-mesa-glx \
    libgl1-mesa-dri xserver-xorg-video-intel pulseaudio

# Parsec Client
RUN install_clean wget \
&&  wget "https://s3.amazonaws.com/parsec-build/package/parsec-linux.deb" -O parsec-linux.deb \ 
&&  dpkg --ignore-depends libsndio6.1 -i parsec-linux.deb # --ignore-depends fixes libsndio \
&&  rm parsec-linux.deb \
&&  apt-get remove -y wget

# Update the parsec client
RUN timeout 20 /usr/bin/parsecd || exit 0

# Setup pulseaudio
COPY pulse-config.conf /etc/pulse/client.conf

# add a parsec user
RUN groupadd --gid 1000 parsec \
&&  useradd --gid 1000 --uid 1000 -m parsec \
&&  usermod -aG video parsec \
&&  mkdir -p /home/parsec/.parsec \
&&  chown parsec:parsec /home/parsec/.parsec

# parsec config
USER parsec
COPY config.txt /home/parsec/.parsec/config.txt
CMD /usr/bin/parsecd
