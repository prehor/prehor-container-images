#!/bin/bash -e

: "${INIT_EMQX_API_HOST:=localhost}"
: "${INIT_EMQX_API_PORT:=18083}"
: "${INIT_EMQX_ACCESS_KEY}"
: "${INIT_EMQX_SECRET_KEY}"
: "${INIT_EMQX_USER}"
: "${INIT_EMQX_PASS}"
: "${INIT_EMQX_TOPIC}"
: "${INIT_EMQX_TOPIC_ACTION:=all}"
: "${INIT_EMQX_TOPIC_PERMISSION:=allow}"
: "${INIT_EMQX_TOPIC_ACLS}"
: "${CURL_PARAMS:=-s}"

INIT_EMQX_BASE_API_URL="http://${INIT_EMQX_ACCESS_KEY}:${INIT_EMQX_SECRET_KEY}@${INIT_EMQX_API_HOST}:${INIT_EMQX_API_PORT}/api/v5"
INIT_EMQX_CHECK_API_URL="${INIT_EMQX_BASE_API_URL}/authentication/password_based:built_in_database/status"
INIT_EMQX_AUTHN_API_URL="${INIT_EMQX_BASE_API_URL}/authentication/password_based:built_in_database/users"
INIT_EMQX_AUTHZ_API_URL="${INIT_EMQX_BASE_API_URL}/authorization/sources/built_in_database/rules/users"

# Wait for EMQX
wait_for_emqx() {
    while ! curl ${CURL_PARAMS} "${INIT_EMQX_CHECK_API_URL}" 2> /dev/null; do
        echo "Waiting for http://{INIT_EMQX_API_HOST}:${INIT_EMQX_API_PORT}"
        sleep 1
    done
    echo
    echo 'EMQX started, ready to initialize';
}

# Authentication
# TODO: check_emqx_user
# TODO: update_emqx_user
create_emqx_user() {
    curl ${CURL_PARAMS} \
        "${INIT_EMQX_AUTHN_API_URL}" \
        -H 'Content-Type: application/json' \
        -d "$(cat <<EOF
{
    "user_id": "${INIT_EMQX_USER}",
    "password": "${INIT_EMQX_PASS}"
}
EOF
        )"
    echo
    echo 'EMQX access key created!'
}

# Authorization
# TODO: check_emqx_rule
# TODO: update_emqx_rule
create_emqx_rule() {
    local INIT_EMQX_TOPIC_USER="$(echo "$1" | cut -d ':' -f 1)"
    local INIT_EMQX_TOPIC_ACTION="$(echo "$1" | cut -d ':' -f 2)"
    local INIT_EMQX_TOPIC_PERMISSION="$(echo "$1" | cut -d ':' -f 3)"
    curl ${CURL_PARAMS} \
        "${INIT_EMQX_AUTHZ_API_URL}" \
        -H 'Content-Type: application/json' \
        -d "$(cat <<EOF
[
{
    "username": "${INIT_EMQX_TOPIC_USER}",
    "rules": [
        {
            "action": "${INIT_EMQX_TOPIC_ACTION}",
            "permission": "${INIT_EMQX_TOPIC_PERMISSION}",
            "topic": "${INIT_EMQX_TOPIC}"
        }
    ]
}
]
EOF
        )"
    echo
}
create_emqx_rules() {
    for INIT_EMQX_TOPIC_ACL in "${INIT_EMQX_USER}:${INIT_EMQX_TOPIC_ACTION}:${INIT_EMQX_TOPIC_PERMISSION}" ${INIT_EMQX_TOPIC_ACLS}; do
        # TODO: check if rule exists
        create_emqx_rule "${INIT_EMQX_TOPIC_ACL}"
    done
    echo 'EMQX authorization created!'

}

# Main
wait_for_emqx
# TODO: check if user exists
create_emqx_user
if [ -n "${INIT_EMQX_TOPIC}" ]; then
    create_emqx_rules
fi
