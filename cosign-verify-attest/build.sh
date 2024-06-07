#!/bin/bash

source functions.sh
source log-functions.sh

# sleep 600
COSIGN_CODE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll do processing at ["${WORKSPACE}"/"${CODEBASE_DIR}"]"
sleep  $SLEEP_DURATION
cd  "${COSIGN_CODE_LOCATION}"
STATUS=0
if [ -z "$IMAGE_NAME" ] || [ -z "$IMAGE_SHA" ]
then
    logInfoMessage "Image name/tag is not provided in env variable $IMAGE_NAME checking it in BP data"
    IMAGE_NAME=`getComponentName`
    IMAGE_TAG=`getRepositoryTag`
    # IMAGE_SHA=`getImageSHA`
    FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
    IMAGE_SHA=$(curl --unix-socket /var/run/docker.sock -s "http://localhost/images/${FULL_IMAGE_NAME}/json" | jq -r '.Id')
fi
FULL_IMAGE_SHA="${IMAGE_NAME}@${IMAGE_SHA}"

logInfoMessage "Executing command"
logInfoMessage "cosign login -u ${REGISTRY_USERNAME} -p <passwd> ${REGISTRY_URL} -d"
cosign login -u $REGISTRY_USERNAME -p $REGISTRY_PASS $REGISTRY_URL
# Check if cosign successful
if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "cosign logged in successfully"
    
else
    TASK_STATUS=1
    logErrorMessage "cosign log in failed"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

logInfoMessage "cosign will SBOM verify the ${FULL_IMAGE_SHA}"

echo "${COSIGN_PUB}" > base.txt

base64 -d base.txt > cosign.pub

logInfoMessage "Executing command"
logInfoMessage "cosign verify-attestation --key cosign.pub --type ${SBOM_FORMAT_TYPE} ${FULL_IMAGE_SHA}" 

cosign verify-attestation --key cosign.pub --insecure-ignore-tlog=true --type ${SBOM_FORMAT_TYPE} ${FULL_IMAGE_SHA}      

# cat report/${OUTPUT_ARG}
# sbom.cdx.intoto.jsonl

# Check if cosign successful
if [ $? -eq 0 ]; then
    TASK_STATUS=0
    logInfoMessage "Successfully verfied SBOM in $FULL_IMAGE_NAME "
else
    TASK_STATUS=1
    logErrorMessage "Failed to verfied SBOM in $FULL_IMAGE_NAME"
    exit 1
fi
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}