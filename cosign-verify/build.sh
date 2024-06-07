#!/bin/bash

source functions.sh
source log-functions.sh

COSIGN_CODE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at ["${WORKSPACE}"/"${CODEBASE_DIR}"]"
sleep  $SLEEP_DURATION
logInfoMessage "I'll do processing at ["${COSIGN_CODE_LOCATION}"]"
cd  "${COSIGN_CODE_LOCATION}"
STATUS=0
if [ -z "$IMAGE_NAME" ] && [ -z "$IMAGE_SHA" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"

    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
    FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
    IMAGE_SHA=$(curl --unix-socket /var/run/docker.sock -s "http://localhost/images/${FULL_IMAGE_NAME}/json" | jq -r '.Id')
    
fi

logInfoMessage "Image Name -> ${IMAGE_NAME}"
logInfoMessage "Image Tag -> ${IMAGE_TAG}"
logInfoMessage "Image SHA Digest -> ${IMAGE_SHA}"
FULL_IMAGE_SHA="${IMAGE_NAME}@${IMAGE_SHA}"

logInfoMessage "Executing command"
logInfoMessage "cosign login -u ${REGISTRY_USERNAME} -p <passwd> ${REGISTRY_URL} -d"

cosign login -u $REGISTRY_USERNAME -p $REGISTRY_PASS $REGISTRY_URL

if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "cosign logged in successfully"
    
else
    TASK_STATUS=1
    logErrorMessage "cosign log in failed"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

logInfoMessage "cosign will verify the ${IMAGE_SHA}"

echo "${COSIGN_PUB}" > base.txt
base64 -d base.txt > cosign.pub

logInfoMessage "Executing command"
logInfoMessage "cosign verify --key cosign.pub --insecure-ignore-tlog=true $IMAGE_NAME@$IMAGE_SHA"

cosign verify --key cosign.pub --insecure-ignore-tlog=true "$IMAGE_NAME@$IMAGE_SHA"

if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "Successfully verified $FULL_IMAGE_SHA with cosign"
    
else
    TASK_STATUS=1
    logErrorMessage "Verification Failed $FULL_IMAGE_SHA"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}