FROM debian:stable-slim
MAINTAINER GP Orcullo

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get --yes --no-install-recommends install \
	v4l-utils ffmpeg libav-tools libjpeg62-turbo libcurl3 python-pip python-setuptools \
	build-essential libcurl4-openssl-dev python-dev libssl-dev automake autoconf curl \
	libjpeg-dev pkgconf libavutil-dev libavformat-dev libavcodec-dev libswscale-dev \
	python-wheel \
    && cd tmp \
    && curl -L https://github.com/Motion-Project/motion/archive/release-4.0.1.tar.gz | tar xzf - \
    && cd motion* \
    && autoreconf -fiv \
    && ./configure --prefix=/usr --without-pgsql --without-sqlite3 --without-mysql --with-ffmpeg=/usr \
    && make \
    && cp motion /usr/bin \
    && cd / \
    && rm -rf /tmp/* \
    && pip install motioneye \
    && rm -rf /root/.cache \
    && apt-get remove --purge -y build-essential libcurl4-openssl-dev python-dev \
    	libssl-dev automake autoconf libjpeg-dev pkgconf libavutil-dev \
	libavformat-dev libavcodec-dev libswscale-dev python-wheel \
    && apt-get autoremove -y \
    && apt-get clean \
    && mkdir /etc/motioneye /var/run/motion \
    && cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf

VOLUME /etc/motioneye
VOLUME /var/lib/motioneye

CMD test -e /etc/motioneye/motioneye.conf || \
    cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf; \
    /usr/local/bin/meyectl startserver -c /etc/motioneye/motioneye.conf

EXPOSE 8765 8080-9000

