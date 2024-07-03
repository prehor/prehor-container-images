FROM ghcr.io/prehor/alpine:3.20@sha256:ec469034f884e3068c0efb7cdff3660a41f7960f94bcde428daf92165062978d

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

COPY ./apps/emqx-init/entrypoint.sh /entrypoint.sh

USER nobody

LABEL org.opencontainers.image.source="https://www.emqx.com"
