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
logInfoMessage "cosign login with ${REGISTRY_USERNAME} ${REGISTRY_URL}"
sleep  $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "cosign login -u ${REGISTRY_USERNAME} -p <passwd> ${REGISTRY_URL} -d"

cosign login -u "${REGISTRY_USERNAME}" -p "${REGISTRY_PASS}" "${REGISTRY_URL}" -d

sleep  $SLEEP_DURATION
logInfoMessage "Executing command"
logInfoMessage "cosign sign --key cosign.key --tlog-upload=false --upload=true --yes ${FULL_IMAGE_SHA}"

echo "${COSIGN_KEY}" > base.txt

base64 -d base.txt > cosign.key

cosign sign --key cosign.key --tlog-upload=false --upload=true --yes "${FULL_IMAGE_SHA}"  


if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "Successfully signed on $FULL_IMAGE_SHA "
else
    TASK_STATUS=1
    logErrorMessage "Failed to sign  $FULL_IMAGE_SHA"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}