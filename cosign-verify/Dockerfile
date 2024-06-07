FROM alpine

RUN apk add --no-cache --upgrade bash
RUN apk add jq 
RUN apk add cosign 
RUN apk add curl 
RUN apk add docker


COPY cosign-verify/build.sh .
COPY BP-BASE-SHELL-STEPS/functions.sh .
COPY BP-BASE-SHELL-STEPS/log-functions.sh .

ENV SLEEP_DURATION ""
ENV IMAGE_NAME ""
ENV IMAGE_SHA ""
ENV REGISTRY_USERNAME ""
ENV REGISTRY_PASS ""
ENV REGISTRY_URL ""

ENTRYPOINT [ "./build.sh" ]
