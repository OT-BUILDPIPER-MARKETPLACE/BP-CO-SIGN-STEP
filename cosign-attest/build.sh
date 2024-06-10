#!/bin/bash

source functions.sh
source log-functions.sh

COSIGN_CODE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at ["${WORKSPACE}"/"${CODEBASE_DIR}"]"
sleep  $SLEEP_DURATION
cd  "${COSIGN_CODE_LOCATION}"
STATUS=0
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_SHA" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    logInfoMessage "Image Name -> ${IMAGE_NAME}"
    logInfoMessage "Image Tag -> ${IMAGE_TAG}"
    logInfoMessage "Image SHA Digest -> ${IMAGE_SHA}"
    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
    FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
    IMAGE_SHA=$(curl --unix-socket /var/run/docker.sock -s "http://localhost/images/${FULL_IMAGE_NAME}/json" | jq -r '.Id')
fi
FULL_IMAGE_SHA="${IMAGE_NAME}@${IMAGE_SHA}"

logInfoMessage "cosign will sign the ${FULL_IMAGE_SHA}"
sleep  $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "cosign attest --key cosign.key --type ${FORMAT_ARG} --predicate report/${REPORT_NAME} --no-upload=true ${FULL_IMAGE_SHA} --yes"

echo "${COSIGN_KEY}" > base.txt

base64 -d base.txt > cosign.key
# changing the file permissions
chmod 600 cosign.key

cosign attest --key cosign.key --type ${FORMAT_ARG} --predicate report/${REPORT_NAME} --no-upload=true ${FULL_IMAGE_SHA} --yes

if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "Successfully attached SBOM with $FULL_IMAGE_NAME "
else
    TASK_STATUS=1
    logErrorMessage "Failed to attach SBOM with $FULL_IMAGE_NAME"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}
