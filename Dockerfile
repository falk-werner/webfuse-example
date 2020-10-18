ARG REGISTRY_PREFIX=''
ARG CODENAME=bionic

FROM ${REGISTRY_PREFIX}ubuntu:${CODENAME} as builder

ARG DEBIAN_FRONTEND=noninteractive
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
        libpam0g-dev \
        nginx \
        fcgiwrap \
        python3 \
        python3-pip \
        python3-setuptools \
        python3-wheel \
    && pip3 install --system meson


ARG PARALLELMFLAGS=-j2

ARG S6OVERLAY_VERSION=2.1.0.0
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6OVERLAY_VERSION}/s6-overlay-amd64.tar.gz" -O s6overlay.tar.gz \
  && tar -xf s6overlay.tar.gz -C / \
  && rm -rf "$builddir"

ARG SOCKLOG_VERSION=3.1.0-2
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/just-containers/socklog-overlay/releases/download/v${SOCKLOG_VERSION}/socklog-overlay-amd64.tar.gz" -O socklog.tar.gz \
  && tar -xf socklog.tar.gz -C / \
  && rm -rf "$builddir"

ARG FUSE_VERSION=3.10.0
RUN set -x \
  && builddeps="udev gettext " \
  && apt install --yes --no-install-recommends $builddeps \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/libfuse/libfuse/archive/fuse-${FUSE_VERSION}.tar.gz" -O libfuse.tar.gz \
  && tar -xf libfuse.tar.gz \
  && cd "libfuse-fuse-$FUSE_VERSION" \
  && meson -Dexamples=false .build \
  && meson install -C .build \
  && rm -rf "$builddir" \
  && apt purge -y $builddeps

ARG WEBSOCKETS_VERSION=4.1.3
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

ARG JANSSON_VERSION=2.13.1
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

ARG WEBFUSE_VERSION=0.5.1
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/falk-werner/webfuse/archive/v${WEBFUSE_VERSION}.tar.gz" -O webfuse.tar.gz \
  && tar -xf webfuse.tar.gz \
  && cd "webfuse-$WEBFUSE_VERSION" \
  && meson -Dwithout_tests=true .build \
  && cd .build \
  && ninja \
  && ninja install \
  && rm -rf "$builddir"

ARG WEBFUSED_VERSION=0.5.0
RUN set -x \
  && builddir="/tmp/out" \
  && mkdir -p "$builddir" \
  && cd "$builddir" \
  && wget "https://github.com/falk-werner/webfused/archive/v${WEBFUSED_VERSION}.tar.gz" -O webfused.tar.gz \
  && tar -xf webfused.tar.gz \
  && cd "webfused-$WEBFUSED_VERSION" \
  && meson -Dwithout_tests=true build \
  && cd build \
  && ninja \
  && ninja install \
  && rm -rf "$builddir"

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
    && rm -rf /tmp/npm-* \
    && rm -rf /tmp/v8-* \
    && mkdir -p /var/www \
    && cp -r ./dist/. /var/www/ \
    && chmod +x /var/www/cgi-bin/*

ARG USERID=1000
RUN set -x \
  && useradd -u "$USERID" -ms /bin/bash user

COPY etc /etc

EXPOSE 8080

ENTRYPOINT ["/init"]
CMD ["/usr/bin/execlineb", "-P", "-c", "emptyenv export HOME /home/user s6-setuidgid user /bin/bash"]