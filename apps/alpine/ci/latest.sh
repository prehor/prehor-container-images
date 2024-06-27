#!/usr/bin/env bash
set -e
version=$(
    curl -s --fail -H "Content-Type: application/json" 'https://hub.docker.com/v2/repositories/library/alpine/tags/?page_size=1000' |
    jq -r '.results|.[]|.name' |
    grep -P '^\d+\.\d+\.\d+$' |
    sort -V -r |
    head -1
)
printf "%s" "${version}"
