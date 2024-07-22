FROM docker.io/library/alpine:3.20.2

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV CHARSET="UTF-8" \
    LANG="en_US.UTF-8"

RUN set -e \
    && \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        curl \
        less \
        \
        hwdata-usb \
        linux-tools-usbip~"${VERSION}"

COPY ./apps/alpine-toolbox/rootfs /
COPY ./apps/usbip/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/torvalds/linux/blob/master/tools/usb/usbip/README"
