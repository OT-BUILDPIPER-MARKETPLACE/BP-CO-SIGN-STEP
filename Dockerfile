FROM alpine:3.19

# -------------------------------------------------------
# Install required base packages
# -------------------------------------------------------
RUN apk add --no-cache \
    bash \
    jq \
    curl \
    ca-certificates \
    wget

# -------------------------------------------------------
# Install Cosign (official binary - stable)
# -------------------------------------------------------
ENV COSIGN_VERSION=v2.2.4

RUN wget -q https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-amd64 \
 && chmod +x cosign-linux-amd64 \
 && mv cosign-linux-amd64 /usr/local/bin/cosign

RUN wget -q https://github.com/google/go-containerregistry/releases/download/v0.19.1/go-containerregistry_Linux_x86_64.tar.gz \
 && tar -xzf go-containerregistry_Linux_x86_64.tar.gz \
 && mv crane /usr/local/bin/ \
 && chmod +x /usr/local/bin/crane \
 && rm -f go-containerregistry_Linux_x86_64.tar.gz
# -------------------------------------------------------
# Create non-root user (UID/GID 65522)
# -------------------------------------------------------
RUN addgroup -g 65522 buildpiper \
 && adduser -D -u 65522 -G buildpiper -s /bin/bash buildpiper

# -------------------------------------------------------
# Prepare directories
# -------------------------------------------------------
RUN mkdir -p /opt/buildpiper/shell-functions /bp /home/buildpiper \
 && chown -R buildpiper:buildpiper /opt/buildpiper /bp /home/buildpiper

# -------------------------------------------------------
# Copy shell functions
# -------------------------------------------------------
COPY BP-BASE-SHELL-STEPS/functions.sh /opt/buildpiper/shell-functions/functions.sh
COPY BP-BASE-SHELL-STEPS/log-functions.sh /opt/buildpiper/shell-functions/log-functions.sh

# -------------------------------------------------------
# Copy build script
# -------------------------------------------------------
COPY build.sh /home/buildpiper/build.sh

RUN chmod +x /home/buildpiper/build.sh \
 && chown buildpiper:buildpiper /home/buildpiper/build.sh

# -------------------------------------------------------
# Environment variables
# -------------------------------------------------------
ENV ACTIVITY_SUB_TASK_CODE=IMAGE_SIGN
ENV SLEEP_DURATION=5
ENV HOME=/home/buildpiper

# Optional: disable experimental sigstore behavior
ENV COSIGN_EXPERIMENTAL=0

# -------------------------------------------------------
# Switch to non-root user
# -------------------------------------------------------
USER buildpiper
WORKDIR /home/buildpiper

# -------------------------------------------------------
# Entrypoint
# -------------------------------------------------------
ENTRYPOINT ["/home/buildpiper/build.sh"]