FROM alpine

RUN apk add --no-cache --upgrade bash
RUN apk add jq 
RUN apk add cosign 
RUN apk add curl 
RUN apk add base64 

COPY cosign-attest/build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY BP-BASE-SHELL-STEPS/log-functions.sh .

ENV SLEEP_DURATION ""
ENV COSIGN_PASSWORD ""

ENTRYPOINT [ "./build.sh" ]
