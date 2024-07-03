FROM ghcr.io/prehor/alpine:3.20@sha256:ec469034f884e3068c0efb7cdff3660a41f7960f94bcde428daf92165062978d

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

RUN \
    apk add --no-cache \
        hwdata-usb \
        linux-tools-usbip~"${VERSION}"

COPY ./apps/usbip/entrypoint.sh /entrypoint.sh

LABEL org.opencontainers.image.source="https://github.com/torvalds/linux/blob/master/tools/usb/usbip/README"
