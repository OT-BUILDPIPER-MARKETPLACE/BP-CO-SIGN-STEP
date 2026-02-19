source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh

COSIGN_CODE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at ["${WORKSPACE}"/"${CODEBASE_DIR}"]"
sleep  $SLEEP_DURATION
cd  "${COSIGN_CODE_LOCATION}"
STATUS=0
SOURCE_FILE_PATH="/bp/data/environment_build"

BUILD_IMAGE_NAME=$(jq -r .build_detail.repository.name < "${SOURCE_FILE_PATH}")
BUILD_IMAGE_TAG=$(jq -r .build_detail.repository.tag < "${SOURCE_FILE_PATH}")
IMAGE=$BUILD_IMAGE_NAME:$BUILD_IMAGE_TAG

#IMAGE_SHA=$(curl --unix-socket /var/run/docker.sock -s "http://localhost/images/${IMAGE}/json" | jq -r '.Id')

logInfoMessage "Image name with tag: $IMAGE"
#logInfoMessage "Image name with tag and sha: $IMAGE@$IMAGE_SHA"

#FULL_IMAGE_SHA="${IMAGE}@${IMAGE_SHA}"
REGISTRY_URL="${IMAGE%%/*}"
logInfoMessage "$REGISTRY_URL"

logInfoMessage "cosign login with ${REGISTRY_USERNAME} ${REGISTRY_URL}"
sleep  $SLEEP_DURATION
logInfoMessage "Executing command"

export COSIGN_PASSWORD="${COSIGN_PASSWORD}"
export SSL_CERT_FILE="${SSL_CERT_FILE}"

logInfoMessage "cosign login -u ${REGISTRY_USERNAME} -p REGISTRY_PASS ${REGISTRY_URL} -d"

cosign login -u "${REGISTRY_USERNAME}" -p "${REGISTRY_PASS}" "${REGISTRY_URL}" -d

if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "cosign logged in successfully"
    
else
    TASK_STATUS=1
    logErrorMessage "cosign log in failed"
    exit 1
fi

if [ ! -f "$COSIGN_KEY_PATH" ]; then
    logErrorMessage "Cosign key not found at $COSIGN_KEY_PATH"
    exit 1
fi

logInfoMessage "cosign will sign the ${IMAGE}"
sleep  $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "cosign sign --key ${COSIGN_KEY_PATH} --tlog-upload=false --upload=true --yes ${IMAGE}"

cosign sign --key "${COSIGN_KEY_PATH}" --tlog-upload=false --upload=true --yes "${IMAGE}"  


if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "Successfully signed on $IMAGE "
else
    TASK_STATUS=1
    logErrorMessage "Failed to sign  $IMAGE"
    exit 1
fi


logInfoMessage "cosign will verify the ${IMAGE}"
logInfoMessage "Executing command"
logInfoMessage "cosign verify --key ${COSIGN_PUB_PATH} --insecure-ignore-tlog=true ${IMAGE}"

cosign verify --key "${COSIGN_PUB_PATH}" --insecure-ignore-tlog=true "${IMAGE}"
TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}