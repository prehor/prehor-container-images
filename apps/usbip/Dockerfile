FROM ghcr.io/prehor/alpine:rolling

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    apk add --no-cache \
        hwdata-usb \
        linux-tools-usbip~"${VERSION}"

COPY ./apps/usbip/entrypoint.sh /entrypoint.sh

LABEL org.opencontainers.image.source="https://github.com/torvalds/linux/blob/master/tools/usb/usbip/README"
