ARG VERSION
FROM docker.io/library/alpine:3.20@sha256:b89d9c93e9ed3597455c90a0b88a8bbb5cb7188438f70953fede212a0c4394e0

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV CHARSET="UTF-8" \
    LANG="en_US.UTF-8" \
    TZ="Etc/UTC"

RUN \
    mkdir /config \
    && \
    adduser app -D -u 568 -g 568 -h /config \
    && \
    chown 568:568 /config \
    && \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        curl \
        grep \
        less

COPY ./apps/alpine/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://alpinelinux.org"
