ARG VERSION
FROM docker.io/library/alpine:3.20

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
