#!/bin/bash

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
: "${CURL_PARAMS:=-s -f -N}"

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
init_emqx_authentication_user() {
    # Check if the user exists
    local INIT_EMQX_USER_ID="$(curl ${CURL_PARAMS} "${INIT_EMQX_AUTHN_API_URL}/${INIT_EMQX_USER}" | jq -r 'try .user_id')"
    if [ "${INIT_EMQX_USER}" == "${INIT_EMQX_USER_ID}" ]; then
        # Update existing user
        curl ${CURL_PARAMS} -XPUT \
            "${INIT_EMQX_AUTHN_API_URL}/${INIT_EMQX_USER}" \
            -H 'Content-Type: application/json' \
            -d "$(cat <<EOF
{
    "is_superuser": false,
    "password": "${INIT_EMQX_PASS}"
}
EOF
            )" | jq -c '.'
        echo "EMQX account '${INIT_EMQX_USER}' updated"
    else
        # Create new user
        curl ${CURL_PARAMS} -XPOST \
            "${INIT_EMQX_AUTHN_API_URL}" \
            -H 'Content-Type: application/json' \
            -d "$(cat <<EOF
{
    "is_superuser": false,
    "password": "${INIT_EMQX_PASS}",
    "user_id": "${INIT_EMQX_USER}"
}
EOF
            )" | jq -c '.'
        echo "EMQX account '${INIT_EMQX_USER}' created"
    fi
}

# Authorization
init_emqx_authorization_user() {
    # Check if the user exists
    if ! curl ${CURL_PARAMS} "${INIT_EMQX_AUTHZ_API_URL}/$1" -o /dev/null; then
        # Create new user
        curl ${CURL_PARAMS} -XPOST \
            "${INIT_EMQX_AUTHZ_API_URL}" \
            -H 'Content-Type: application/json' \
            -d "$(cat <<EOF
[
    {
        "username": "$1",
        "rules": []
    }
]
EOF
            )"
        curl ${CURL_PARAMS} "${INIT_EMQX_AUTHZ_API_URL}/$1" | jq -c '.'
        echo "EMQX authorization for user '$1' created"
    fi
}
init_emqx_authorization_rule() {
    local INIT_EMQX_TOPIC_USER="$(echo "$1" | cut -d ':' -f 1)"
    local INIT_EMQX_TOPIC="$(echo "$1" | cut -d ':' -f 2)"
    local INIT_EMQX_TOPIC_ACTION="$(echo "$1" | cut -d ':' -f 3)"
    local INIT_EMQX_TOPIC_PERMISSION="$(echo "$1" | cut -d ':' -f 4)"

    # Be sure that the authorized user exists
    init_emqx_authorization_user "${INIT_EMQX_TOPIC_USER}"

    # Get other rules
    local INIT_EMQX_TOPIC_OTHER_RULES="$(curl ${CURL_PARAMS} "${INIT_EMQX_AUTHZ_API_URL}/${INIT_EMQX_TOPIC_USER}" | jq -c ".rules[] | select(.topic != \"${INIT_EMQX_TOPIC}\")"  | tr '\n' ' ')"

    # Get new rule
    local INIT_EMQX_TOPIC_RULE="{\"action\": \"${INIT_EMQX_TOPIC_ACTION}\",\"permission\": \"${INIT_EMQX_TOPIC_PERMISSION}\",\"topic\": \"${INIT_EMQX_TOPIC}\"}"

    #  Get updated rules
    local INIT_EMQX_TOPIC_RULES="$(echo "${INIT_EMQX_TOPIC_RULE}${INIT_EMQX_TOPIC_OTHER_RULES}" | sed -E 's/\}\s*\{/},{/g')"

    # Update rules
    curl ${CURL_PARAMS} -XPUT \
        "${INIT_EMQX_AUTHZ_API_URL}/${INIT_EMQX_TOPIC_USER}" \
        -H 'Content-Type: application/json' \
        -d "$(cat <<EOF
    {
        "username": "${INIT_EMQX_TOPIC_USER}",
        "rules": [${INIT_EMQX_TOPIC_RULES}]
    }
EOF
        )"
    curl ${CURL_PARAMS} "${INIT_EMQX_AUTHZ_API_URL}/${INIT_EMQX_TOPIC_USER}" | jq -c '.' # jq -c "try .rules[] | select(.topic == \"${INIT_EMQX_TOPIC}\")"
    echo "EMQX authorization rule '$1' updated"

}
init_emqx_authorization_rules() {
    for INIT_EMQX_TOPIC_ACL in $1; do
        init_emqx_authorization_rule "${INIT_EMQX_TOPIC_ACL}"
    done
}

# Main
echo
echo
echo
wait_for_emqx
init_emqx_authentication_user
if [ -n "${INIT_EMQX_TOPIC}" ]; then
    init_emqx_authorization_rules "${INIT_EMQX_USER}:${INIT_EMQX_TOPIC}:${INIT_EMQX_TOPIC_ACTION}:${INIT_EMQX_TOPIC_PERMISSION} ${INIT_EMQX_TOPIC_ACLS}"
fi
