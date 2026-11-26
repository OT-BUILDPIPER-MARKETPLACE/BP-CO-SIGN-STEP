#!/bin/bash

source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source /opt/buildpiper/shell-functions/str-functions.sh
source /opt/buildpiper/shell-functions/file-functions.sh
source /opt/buildpiper/shell-functions/aws-functions.sh
source /opt/buildpiper/shell-functions/getDataFile.sh

login_registry() {

    local TARGET_URL="$1"
    local JSON_FILE="/bp/data/environment_build"

    if [[ -z "$TARGET_URL" ]]; then
        logErrorMessage "Registry URL is required."
        return 1
    fi

    [[ -f "$JSON_FILE" ]] || {
        logErrorMessage "JSON file not found: $JSON_FILE"
        return 1
    }

    [[ -n "$FERNET_KEY" ]] || {
        logErrorMessage "FERNET_KEY is not set"
        return 1
    }

    local FOUND=false

    while read -r reg; do

        NAME=$(jq -r '.name // empty' <<<"$reg")
        URL=$(jq -r '.url // empty' <<<"$reg")
        ENC_USER=$(jq -r '.username // empty' <<<"$reg")
        ENC_PASS=$(jq -r '.password // empty' <<<"$reg")

        # Normalize registry URLs by removing protocol and trailing slash
        NORMALIZED_URL="${URL#https://}"
        NORMALIZED_URL="${NORMALIZED_URL#http://}"
        NORMALIZED_URL="${NORMALIZED_URL%/}"
        
        NORMALIZED_TARGET="${TARGET_URL#https://}"
        NORMALIZED_TARGET="${NORMALIZED_TARGET#http://}"
        NORMALIZED_TARGET="${NORMALIZED_TARGET%/}"
        
        [[ "$NORMALIZED_URL" != "$NORMALIZED_TARGET" ]] && continue

        FOUND=true

        USERNAME=$(python3 - <<PY
from cryptography.fernet import Fernet
import os
print(Fernet(os.environ["FERNET_KEY"].encode()).decrypt(b"$ENC_USER").decode())
PY
) || {
            logErrorMessage "Failed to decrypt username for $NAME"
            return 1
        }

        PASSWORD=$(python3 - <<PY
from cryptography.fernet import Fernet
import os
print(Fernet(os.environ["FERNET_KEY"].encode()).decrypt(b"$ENC_PASS").decode())
PY
) || {
            logErrorMessage "Failed to decrypt password for $NAME"
            return 1
        }
        
        # Normalize registry URL
        REGISTRY_HOST="${URL#https://}"
        REGISTRY_HOST="${REGISTRY_HOST#http://}"
        REGISTRY_HOST="${REGISTRY_HOST%/}"
        # logInfoMessage "Logging into Docker registry: $NAME ($URL)"

        # echo "$PASSWORD" | docker login \
        #     "$URL" \
        #     --username "$USERNAME" \
        #     --password-stdin

        # if [[ $? -ne 0 ]]; then
        #     logErrorMessage "Docker login failed for $URL"
        #     return 1
        # fi

        # logInfoMessage "Docker login successful."


        logInfoMessage "Logging into Crane registry: $NAME ($REGISTRY_HOST)"

        crane auth login \
            -u "$USERNAME" \
            -p "$PASSWORD" \
            "$REGISTRY_HOST"

        if [[ $? -ne 0 ]]; then
            logErrorMessage "Crane login failed for $REGISTRY_HOST"
            return 1
        fi

        logInfoMessage "Crane login successful."

        return 0

    done < <(
        jq -c '
            if (.registry | type) == "array" then
                .registry[]
            else
                .registry
            end
        ' "$JSON_FILE"
    )

    if [[ "$FOUND" = false ]]; then
        logErrorMessage "No registry configuration found for: $TARGET_URL"
        return 1
    fi
}