#!/bin/bash

: "${USBIP_HOST:=localhost}"  # Remote host
: "${USBIP_PORT:=3240}"       # Remote port
: "${USBIP_RETRY:=5}"         # Attach retry period
: "${USBIP_LOOP_FILE:=$(mktemp)}"

# Attach device
attach_device() {
    local ID="$1"

    detach_device "${ID}"
    usbip -t "${USBIP_PORT}" attach -r "${USBIP_HOST}" -b "${ID}" 2>/dev/null
    echo "INFO: Device usbip://${USBIP_HOST}:${USBIP_PORT}/${ID} was attached"
}

# Detach devices on unreachable host
clean_unreachable_devices() {
    ping -W 5 -c 1 "${USBIP_HOST}" 2>&1 > /dev/null && return
    echo -n | timeout 1 cat > "/dev/tcp/${USBIP_HOST}/${USBIP_PORT}" 2>&1 > /dev/null && return
    echo "WARNING: Device usbip://${USBIP_HOST}:${USBIP_PORT} is unreachable"
    detach_device
}

# Detach device
detach_device() {
    # Empty ID will remove all remote host devices
    local ID=$1

    PORTS=$(usbip port | grep -B2 "\-> usbip://${USBIP_HOST}:${USBIP_PORT}/${ID}" | \
    grep '^Port' | cut -d' ' -f 2 | cut -d':' -f1)
    for PORT in ${PORTS}; do
        usbip detach -p "${PORT}" 2>&1 > /dev/null
        echo "INFO: Device usbip://${USBIP_HOST}:${USBIP_PORT}/${ID} was detached"
    done
}

# Get remote devices id list
get_device_list() {
    echo $(usbip -t "${USBIP_PORT}" list -r "${USBIP_HOST}" 2>/dev/null | \
    grep -oP '^[[:blank:]]+[[:digit:]]+-.*?:' | \
    awk -F' ' '{print $1}' | cut -d':' -f 1)
}

# Attach all devices
start_attach_loop () {
    touch "${USBIP_LOOP_FILE}"
    while [ -e "${USBIP_LOOP_FILE}" ]; do
        local ID_LIST=$(get_device_list)
        if [ -z "${ID_LIST}" ]; then
            clean_unreachable_devices
        else
            for ID in ${ID_LIST}; do
                attach_device "${ID}"
            done
        fi

        sleep "${USBIP_RETRY}"
    done
    detach_device
}

# Detach all devices
stop_attach_loop() {
    rm -f "${USBIP_LOOP_FILE}"
}

# Main
case "${1}" in
    ''|'--attach')
        start_attach_loop
        ;;
    '--detach')
        stop_attach_loop
        ;;
    *)
        echo "ERROR: Unknown option '${1}'" > /dev/stderr
        exit 1
esac
