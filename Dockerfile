FROM alpine:3.19

# -------------------------------------------------------
# Install required packages
# -------------------------------------------------------
RUN apk add --no-cache \
    bash \
    jq \
    cosign \
    curl

# -------------------------------------------------------
# Create non-root user (UID/GID 65522)
# -------------------------------------------------------
RUN addgroup -g 65522 buildpiper \
 && adduser -D -u 65522 -G buildpiper -s /bin/bash buildpiper

# -------------------------------------------------------
# Prepare directories
# -------------------------------------------------------
RUN mkdir -p /opt/buildpiper/shell-functions /bp \
 && chown -R buildpiper:buildpiper /opt/buildpiper /bp

# -------------------------------------------------------
# Copy shell functions
# -------------------------------------------------------
COPY BP-BASE-SHELL-STEPS/functions.sh /opt/buildpiper/shell-functions/functions.sh
COPY BP-BASE-SHELL-STEPS/log-functions.sh /opt/buildpiper/shell-functions/log-functions.sh

# -------------------------------------------------------
# Copy build script
# -------------------------------------------------------
COPY build.sh /opt/buildpiper/build.sh
RUN chmod +x /opt/buildpiper/build.sh \
 && chown buildpiper:buildpiper /opt/buildpiper/build.sh

# -------------------------------------------------------
# Environment variables
# -------------------------------------------------------
ENV ACTIVITY_SUB_TASK_CODE=IMAGE_SIGN
ENV SLEEP_DURATION=5

# -------------------------------------------------------
# Switch to non-root user
# -------------------------------------------------------
USER buildpiper
WORKDIR /opt/buildpiper

# -------------------------------------------------------
# Entrypoint
# -------------------------------------------------------
ENTRYPOINT ["/opt/buildpiper/build.sh"]
