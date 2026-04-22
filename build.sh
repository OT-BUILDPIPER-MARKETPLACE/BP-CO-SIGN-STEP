#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

COSIGN_CODE_LOCATION="${WORKSPACE}/${CODEBASE_DIR}"
logInfoMessage "I'll do processing at [${COSIGN_CODE_LOCATION}]"

sleep $SLEEP_DURATION
cd "${COSIGN_CODE_LOCATION}" || exit 1

SOURCE_FILE_PATH="/bp/data/environment_build"

BUILD_IMAGE_NAME=$(jq -r .build_detail.repository.name < "${SOURCE_FILE_PATH}")
BUILD_IMAGE_TAG=$(jq -r .build_detail.repository.tag < "${SOURCE_FILE_PATH}")

IMAGE="${BUILD_IMAGE_NAME}:${BUILD_IMAGE_TAG}"
REGISTRY_URL="${IMAGE%%/*}"

logInfoMessage "Image: ${IMAGE}"
logInfoMessage "Registry: ${REGISTRY_URL}"

# -----------------------------
# Crane Login
# -----------------------------
logInfoMessage "Logging into registry for crane"

crane auth login \
  -u "${REGISTRY_USERNAME}" \
  -p "${REGISTRY_PASS}" \
  "${REGISTRY_URL}"

if [ $? -ne 0 ]; then
  logErrorMessage "crane login failed"
  exit 1
fi

# -----------------------------
# Get Digest
# -----------------------------
IMAGE_DIGEST=$(crane digest "$IMAGE")

if [ -z "$IMAGE_DIGEST" ]; then
  logErrorMessage "Failed to fetch digest for $IMAGE"
  exit 1
fi

FULL_IMAGE="${IMAGE}@${IMAGE_DIGEST}"
logInfoMessage "Resolved image: ${FULL_IMAGE}"

# -----------------------------
# Validate key
# -----------------------------
if [ ! -f "$COSIGN_KEY_PATH" ]; then
  logErrorMessage "Cosign key not found at $COSIGN_KEY_PATH"
  exit 1
fi

# -----------------------------
# Sign
# -----------------------------
logInfoMessage "Signing image: ${FULL_IMAGE}"
logInfoMessage "Executing .... cosign sign --key ${COSIGN_KEY_PATH} --tlog-upload=false --upload=true --yes ${FULL_IMAGE}"

cosign sign --key "${COSIGN_KEY_PATH}" --tlog-upload=false --upload=true --yes "${FULL_IMAGE}"

if [ $? -ne 0 ]; then
  logErrorMessage "Signing failed for ${FULL_IMAGE}"
  exit 1
fi

logInfoMessage "Successfully signed ${FULL_IMAGE}"

# -----------------------------
# Verify
# -----------------------------
logInfoMessage "Verifying image: ${FULL_IMAGE}"
logInfoMessage "Executing ....cosign verify --key ${COSIGN_PUB_PATH} --offline --insecure-ignore-tlog=true ${FULL_IMAGE}"

cosign verify --key "${COSIGN_PUB_PATH}" --offline --insecure-ignore-tlog=true "${FULL_IMAGE}"

TASK_STATUS=$?

if [ $TASK_STATUS -ne 0 ]; then
  logErrorMessage "Verification failed for ${FULL_IMAGE}"
  exit 1
fi

logInfoMessage "Verification successful"

# -----------------------------
# Save status
# -----------------------------
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}