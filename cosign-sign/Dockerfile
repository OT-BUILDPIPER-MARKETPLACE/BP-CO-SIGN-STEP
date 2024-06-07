FROM alpine

RUN apk add --no-cache --upgrade bash
RUN apk add jq 
RUN apk add cosign 
RUN apk add curl 

COPY cosign-sign/build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY BP-BASE-SHELL-STEPS/log-functions.sh .

ENV SLEEP_DURATION ""
ENV COSIGN_PASSWORD ""

# COSIGN_KEY = base64 encoded cosign.key

ENV COSIGN_KEY ""  

# registry login creds to push signed image

ENV REGISTRY_USERNAME ""
ENV REGISTRY_PASS ""
ENV REGISTRY_URL ""

ENTRYPOINT [ "./build.sh" ]
