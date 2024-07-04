FROM docker.io/library/alpine:3.20.1

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV CHARSET="UTF-8" \
    LANG="en_US.UTF-8"

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
        less

COPY ./apps/alpine-toolbox/rootfs /
COPY ./apps/emqx-init/entrypoint.sh /entrypoint.sh

USER app
WORKDIR /config

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://www.emqx.com"
