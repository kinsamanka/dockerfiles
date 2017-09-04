FROM alpine:3.6
MAINTAINER GP Orcullo

ENV MOTION_VER 4.0.1
ADD *.patch /tmp/

RUN apk add --no-cache autoconf automake curl-dev ffmpeg-dev gcc jpeg-dev\
	linux-headers make musl-dev openssl-dev python-dev py-pip \
	bash curl ffmpeg ffmpeg-libs libcurl libcrypto1.0 libjpeg python \
	py-setuptools v4l-utils \
    && pip install --upgrade pip motioneye \
    && cd /tmp \
    && curl -L https://github.com/Motion-Project/motion/archive/release-${MOTION_VER}.tar.gz | tar xvzf - \
    && cd motion* \
    && patch -Np1 < /tmp/strerror_r.patch \
    && patch -Np1 < /tmp/pthread.patch \
    && autoreconf -fiv \
    && ./configure \
    && make \
    && cp motion /usr/bin \
    && cd / \
    && rm -rf /tmp/* \
    && apk --purge -v del autoconf automake curl-dev ffmpeg-dev gcc jpeg-dev \
	linux-headers make musl-dev openssl-dev python-dev py-pip \
    && mkdir /etc/motioneye/ /var/lib/motioneye \
    && cp /usr/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf \
    && chown -R operator:nogroup /etc/motioneye /var/lib/motioneye /var/log \
    && chmod a+rw /run /var/run \
    && mkdir -p /data /data.org/conf \
    && chmod 0777 -R /data.org \
    && mv /etc/motioneye /data.org/conf \
    && mv /var/lib/motioneye /data.org \
    && mv /var/log /data.org \
    && ln -sf /data/conf/motioneye /etc/motioneye \
    && ln -sf /data/motioneye /var/lib/motioneye \
    && ln -sf /data/log /var/log \
    && mkdir /data/conf \
    && ln -sf /data.org/conf/motioneye /data/conf/motioneye \
    && ln -sf /data.org/motioneye /data/motioneye \
    && ln -sf /data.org/log /data/log \
    && touch /data/.ok \
    && chown -R operator /data 

VOLUME /data

CMD test ! -f /data/.ok && \
	(cp -a /data.org/* /data; touch /data/.ok); \
    su operator -c "/usr/bin/meyectl startserver -c /etc/motioneye/motioneye.conf"

EXPOSE 8765 

