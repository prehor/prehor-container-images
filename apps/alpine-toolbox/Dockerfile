ARG VERSION
FROM docker.io/library/alpine:${VERSION}

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV CHARSET="UTF-8" \
    LANG="en_US.UTF-8" \
    ENTRYPOINT_COMMAND="/bin/bash"

RUN set -e \
    && \
    addgroup app -g 568 \
    && \
    adduser app -D -u 568 -G app -h /config \
    && \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        curl \
        less \
        \
        git \
        openssl \
    && \
    sed -i -E 's/^(.*(CHARSET|LANG)=)/#\1/' /etc/profile

COPY ./apps/alpine-toolbox/rootfs /
COPY ./apps/alpine-toolbox/entrypoint.sh /entrypoint.sh

USER app
WORKDIR /config

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://alpinelinux.org"
