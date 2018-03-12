
# FROM resin/rpi-raspbian
FROM python:2.7
EXPOSE 5000
LABEL maintainer "Mike Petonic - petonic@yahoo.com  "

ENV CURA_VERSION=15.04.6
ARG tag=master

WORKDIR /opt/octoprint


#install ffmpeg
RUN cd /tmp \
  && wget -O ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-32bit-static.tar.xz \
	&& mkdir -p /opt/ffmpeg \
	&& tar xvf ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
  && rm -Rf /tmp/*

#install Cura
RUN set -x && set -v && cd /tmp \
  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && tar -zxf ${CURA_VERSION}.tar.gz \
	&& cd CuraEngine-${CURA_VERSION} \
	&& mkdir build \
	&& make \
	&& mv -f ./build /opt/cura/ \
  && rm -Rf /tmp/*

#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
RUN  usermod -a -G dialout octoprint \
  && usermod -a -G tty octoprint
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint
#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

#Install Octoprint
RUN  git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
	&& ./venv/bin/python setup.py install

#Change permissions on /dev/ttyACM0 to be group "dialout"
USER root

#Install gpio for control of the LED lights, etc.
RUN  python2 -m pip install gpio

#RUN  mknod /dev/ttyACM0 c 166 0 \
#  && chgrp dialout /dev/ttyACM0 \
#  && chmod a+rw /dev/ttyACM0

COPY udev_rules.d /etc/udev/rules.d/98-octoprint.rules


VOLUME /home/octoprint/.octoprint

###########
# Install HA Proxy
###########
USER root
RUN apt-get update && apt-get install -y --no-install-recommends haproxy
CMD service haproxy stop; /bin/true

EXPOSE 80 5000

COPY haproxy.cfg /etc/haproxy/haproxy.cfg
RUN echo 'ENABLED=1' >> /etc/default/haproxy

ENV INITSYSTEM on

#COPY rc.local /etc/rc.local
#COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD service haproxy start

ENV CAMERA_DEV "/dev/video0"
ENV STREAMER_FLAGS "-y -n"

# Make a tight SETEUID program and install it to SCRIPTS
CMD cd /home/octoprint/.octoprint/src \
  && gcc -o switch_gpio switch_gpio.c \
  && chmod ug+s switch_gpio \
  && mv switch_gpio ../scripts


##################
###
### Switch to user OCTOPRINT.  For security and also
### because the OctoPrint package requires it.
###
##################
USER octoprint

##########
# Install Plugins
##########
RUN /opt/octoprint/venv/bin/python -m pip install https://github.com/OctoPrint/OctoPrint-MalyanConnectionFix/archive/master.zip

##########
# Run OctoPrint server
##########
CMD ["/opt/octoprint/venv/bin/octoprint", "serve"]
# CMD ["/usr/sbin/chroot", "--userspec=octoprint:octoprint", "/", "/opt/octoprint/venv/bin/octoprint", "serve"]
