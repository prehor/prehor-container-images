FROM docker.io/library/alpine:3.20.1

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
        curl

COPY ./apps/emqx-init/entrypoint.sh /entrypoint.sh

USER app

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://www.emqx.com"
