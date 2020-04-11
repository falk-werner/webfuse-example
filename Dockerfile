ARG REGISTRY_PREFIX=''
ARG CODENAME=bionic

FROM ${REGISTRY_PREFIX}ubuntu:${CODENAME} as builder

RUN set -x \
    && apt update \
    && apt upgrade -y \
    && apt install --yes --no-install-recommends \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \        
        ca-certificates \
        openssl \
        libssl-dev \
        uuid-dev \
        wget \
        libconfig-dev \
        libpam0g-dev

ARG PARALLELMFLAGS=-j2

ARG DUMB_INIT_VERSION=1.2.2
RUN set -x \
  && builddeps="xxd" \
  && apt install --yes --no-install-recommends $builddeps \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/Yelp/dumb-init/archive/v${DUMB_INIT_VERSION}.tar.gz" -O dumb_init.tar.gz \
  && tar -xf dumb_init.tar.gz \
  && cd "dumb-init-$DUMB_INIT_VERSION" \
  && make "$PARALLELMFLAGS" \
  && chmod +x dumb-init \
  && mv dumb-init /usr/local/bin/dumb-init \
  && dumb-init --version \
  && rm -rf "$builddir" \
  && apt purge -y $builddeps

ARG FUSE_VERSION=3.9.1
RUN set -x \
  && builddeps="udev gettext python3 python3-pip python3-setuptools python3-wheel" \
  && apt install --yes --no-install-recommends $builddeps \
  && pip3 install --system meson \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/libfuse/libfuse/archive/fuse-${FUSE_VERSION}.tar.gz" -O libfuse.tar.gz \
  && tar -xf libfuse.tar.gz \
  && cd "libfuse-fuse-$FUSE_VERSION" \
  && mkdir .build \
  && cd .build \
  && meson .. \
  && ninja \
  && ninja install \
  && pip3 uninstall -y meson \
  && rm -rf "$builddir" \
  && apt purge -y $builddeps

ARG WEBSOCKETS_VERSION=3.2.0
RUN set -x \
  && apt install --yes --no-install-recommends \
       ca-certificates \
       openssl \
       libssl-dev \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/warmcat/libwebsockets/archive/v${WEBSOCKETS_VERSION}.tar.gz" -O libwebsockets.tar.gz \
  && tar -xf libwebsockets.tar.gz \
  && cd "libwebsockets-$WEBSOCKETS_VERSION" \
  && mkdir .build \
  && cd .build \
  && cmake .. \
  && make "$PARALLELMFLAGS" install \
  && rm -rf "$builddir"

ARG JANSSON_VERSION=2.12
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/akheron/jansson/archive/v${JANSSON_VERSION}.tar.gz" -O jansson.tar.gz \
  && tar -xf jansson.tar.gz \
  && cd "jansson-$JANSSON_VERSION" \
  && mkdir .build \
  && cd .build \
  && cmake -DJANSSON_BUILD_DOCS=OFF ".." \
  && make "$PARALLELMFLAGS" install \
  && rm -rf "$builddir"

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

ARG WEBFUSE_VERSION=0.2.0
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/falk-werner/webfuse/archive/v${WEBFUSE_VERSION}.tar.gz" -O webfuse.tar.gz \
  && tar -xf webfuse.tar.gz \
  && cd "webfuse-$WEBFUSE_VERSION" \
  && mkdir .build \
  && cd .build \
  && cmake -DWITHOUT_TESTS=ON -DWITHOUT_EXAMPLE=ON ".." \
  && make "$PARALLELMFLAGS" install \
  && rm -rf "$builddir"

ARG WEBFUSED_VERSION=0.2.0
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/falk-werner/webfused/archive/v${WEBFUSED_VERSION}.tar.gz" -O webfused.tar.gz \
  && tar -xf webfused.tar.gz \
  && cd "webfused-$WEBFUSED_VERSION" \
  && mkdir .build \
  && cd .build \
  && cmake -DWITHOUT_TESTS=ON ".." \
  && make "$PARALLELMFLAGS" install \
  && rm -rf "$builddir"

COPY webfused.conf /etc

ARG NPM_VERSION=">=6.14.0 <7.0.0"
ARG NODEJS_VERSION=12
RUN set -x \
    && apt update \
    && apt upgrade -y \
    && apt install --yes --no-install-recommends \
      nodejs \
      npm \
    && npm install -g npm@"${NPM_VERSION}" \
    && npm install -g n \
    && n "${NODEJS_VERSION}"

COPY www /usr/local/src/www
RUN set -x \
    && cd /usr/local/src/www \
    && npm update --no-save \
    && npm run build \
    && mkdir -p /var/www \
    && cp -r ./dist/. /var/www/

ARG USERID=1000
RUN set -x \
  && useradd -u "$USERID" -ms /bin/bash user

EXPOSE 8080

ENTRYPOINT ["dumb-init", "--"]