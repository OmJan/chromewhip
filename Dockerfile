FROM ubuntu:16.04

MAINTAINER Charlie Smith <charlie@chuckus.nz>

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DISPLAY=:99

RUN  echo "deb http://archive.ubuntu.com/ubuntu xenial main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main universe\n" >> /etc/apt/sources.list \
  && echo "deb http://security.ubuntu.com/ubuntu xenial-security main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy
RUN apt-get install -y software-properties-common python-software-properties tzdata

RUN add-apt-repository ppa:fkrull/deadsnakes
RUN apt-get update -qqy

ENV TZ "UTC"
RUN echo "${TZ}" > /etc/timezone \
  && dpkg-reconfigure --frontend noninteractive tzdata

# RUN apt-get -y install python3.6 xvfb \
# TODO: remove once gui render.png working
RUN apt-get -y install python3.6 xvfb curl
#  && rm /etc/apt/sources.list.d/debian.list \
#  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN set -xe \
    && curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable
#    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable x11vnc fluxbox
RUN mkdir -p ~/.vnc \
  && x11vnc -storepasswd secret ~/.vnc/passwd

COPY scripts/get-pip.py /tmp/
RUN python3.6 /tmp/get-pip.py && rm /tmp/get-pip.py

RUN mkdir /usr/jsprofiles
WORKDIR /usr/src/app

COPY requirements.txt ./

RUN pip3.6 install --no-cache-dir -r requirements.txt

COPY . .

COPY scripts/run_chromewhip_linux.sh .
ENTRYPOINT [ "bash", "run_chromewhip_linux.sh" ]
