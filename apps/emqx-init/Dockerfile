FROM ghcr.io/prehor/alpine:3.20@sha256:3f10abffcc9280fe75c2598bf6260f7c7ce86e9cc25756fa8dabe0da8e3a954b

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

COPY ./apps/emqx-init/entrypoint.sh /entrypoint.sh

USER nobody

LABEL org.opencontainers.image.source="https://www.emqx.com"
