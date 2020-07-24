FROM debian:stable
MAINTAINER Michael Schaefer

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
apt-get -y install \
build-essential \
libssl-dev \
python \
g++ \
libavahi-compat-libdnssd-dev \
curl \
ssh \
netcat \
wget

# NodeJS
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='amd64';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  && if [ "$ARCH" = "amd64" ]; then \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs ; fi \
  && if [ "$ARCH" = "arm64" ]; then \
    wget https://nodejs.org/dist/v14.6.0/node-v14.6.0-linux-arm64.tar.xz \
    && tar -xvf node-v14.6.0-linux-arm64.tar.xz \
    && cp -R node-v14.6.0-linux-arm64/* /usr/local/ ; fi \
  && if [ "$ARCH" = "armv7l" ]; then \
    wget https://nodejs.org/dist/v14.6.0/node-v14.6.0-linux-armv7l.tar.xz \
    && tar -xvf node-v14.6.0-linux-armv7l.tar.xz \
    && cp -R node-v14.6.0-linux-armv7l/* /usr/local/ ; fi



RUN npm install -g alexa-fhem && \
mkdir /root/.alexa && mkdir /opt/alexa

COPY /etc/startup.sh /opt/alexa/startup.sh

HEALTHCHECK --interval=10s --timeout=10s --start-period=30s --retries=3 CMD nc -z 127.0.0.1 3000 || exit 1

EXPOSE 3000
CMD ["/opt/alexa/startup.sh"]
