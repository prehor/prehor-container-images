FROM ghcr.io/prehor/alpine:3.20@sha256:3f10abffcc9280fe75c2598bf6260f7c7ce86e9cc25756fa8dabe0da8e3a954b

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    apk add --no-cache \
        hwdata-usb \
        linux-tools-usbip~"${VERSION}"

COPY ./apps/usbip/entrypoint.sh /entrypoint.sh

LABEL org.opencontainers.image.source="https://github.com/torvalds/linux/blob/master/tools/usb/usbip/README"
