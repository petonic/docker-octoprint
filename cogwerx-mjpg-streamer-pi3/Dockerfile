## Docker build for a base raspbian image with mjpg-streamer libraries for Raspberry Pi3
## MJPEG Streamer intro and manual build
# http://petrkout.com/electronics/low-latency-0-4-s-video-streaming-from-raspberry-pi-mjpeg-streamer-opencv/

## Start from resin.io's image    126MB
FROM resin/rpi-raspbian

RUN apt-get update && apt-get install -y --no-install-recommends apt-utils \
 && apt-get install -y --no-install-recommends git joe libv4l-dev libjpeg8-dev imagemagick build-essential cmake subversion
# +234 MB

## Set up mjpeg streamer, clone, and build
WORKDIR /usr/src
RUN mkdir mjpg-streamer
RUN chown `whoami`:users mjpg-streamer
WORKDIR /usr/src/mjpg-streamer

RUN git clone https://github.com/jacksonliam/mjpg-streamer.git .
# +3.5MB

WORKDIR /usr/src/mjpg-streamer/mjpg-streamer-experimental
RUN make
RUN export LD_LIBRARY_PATH=.

COPY ./cam-binaries/input_raspicam.so /usr/src/mjpg-streamer/mjpg-streamer-experimental
COPY ./cam-binaries/*.so /usr/src/mjpg-streamer/mjpg-streamer-experimental/

# Expose port (will also be exposed explicitly during container run)
EXPOSE 8080

# For docker build --squash (saves 150+MB)
RUN apt-get purge build-essential cmake perl apt-utils subversion && apt-get autoremove  && apt-get clean && rm -rf /usr/share/locale

# Configure ha_proxy
# COPY haproxy.cfg /etc

### To verify that it's working:
## Run this command upon container start, to stream on LAN on port 8080
## Uses standard picam options (Vertical flip: -vf / Horizontal flip: -hf)
#RUN ./mjpg_streamer -o "output_http.so -w ./www" -i "input_raspicam.so -x 640 -y 480 -fps 20 -ex night"

## Full docker container run command (vertically flipped):
# docker run -it --rm --privileged -p 8080:8080 openhorizon/mjpg-streamer-pi3 ./mjpg_streamer -o "output_http.so -w ./www" -i "input_raspicam.so -x 640 -y 480 -fps 20 -ex night -vf"
