FROM ghcr.io/prehor/alpine:rolling

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

COPY ./apps/emqx-init/entrypoint.sh /entrypoint.sh

USER nobody

LABEL org.opencontainers.image.source="https://www.emqx.com"
