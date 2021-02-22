# Start with the Vrbo packer container and add the
# IBM cloud packer plugin
#

# These args must be present on the "build" command.
ARG PACKER_CONTAINER_VERSION
ARG PACKER_CONTAINER_URL

FROM ${PACKER_CONTAINER_URL}:${PACKER_CONTAINER_VERSION}

# These must be present on the build command
ARG PLUGIN_SHA
ARG PLUGIN_VERSION
ARG PLUGIN_GIT_URL

# These can optionally be supplied with the build command
ARG RUN_AS=ubuntu
ARG SSH_KEY_NAME=id_rsa

RUN wget --quiet -O /bin/packer-builder-ibmcloud_${PLUGIN_VERSION}_alpine_64-bit.tar.gz ${PLUGIN_GIT_URL}/v${PLUGIN_VERSION}/packer-builder-ibmcloud_${PLUGIN_VERSION}_alpine_64-bit.tar.gz
RUN echo "${PLUGIN_SHA} */bin/packer-builder-ibmcloud_${PLUGIN_VERSION}_alpine_64-bit.tar.gz" | sha256sum -c -
RUN tar xv -f /bin/packer-builder-ibmcloud_${PLUGIN_VERSION}_alpine_64-bit.tar.gz -C /bin
RUN chmod +x /bin/packer-builder-ibmcloud

RUN if ! getent passwd ${RUN_AS} >/dev/null; then \
        addgroup ${RUN_AS} && \
        adduser -D -G ${RUN_AS} ${RUN_AS}; \
    fi; \
    sshdir=`getent passwd ${RUN_AS} | cut -d: -f6)`/.ssh; if [ ! -d ${sshdir} ]; then \
        mkdir ${sshdir}; \
    fi; \
    touch $sshdir/${SSH_KEY_NAME} $sshdir/${SSH_KEY_NAME}.pub; \
    chown -R ${RUN_AS} ${sshdir}; \
    chmod 600 ${sshdir}/${SSH_KEY_NAME}*

RUN apk add --no-cache \
  python3 \
  python3-dev \
  openssh \
  ansible
RUN python3 -m ensurepip && pip3 install --upgrade pip

RUN rm -rf /var/cache/apk/*

USER ${RUN_AS}

VOLUME /workdir
WORKDIR /workdir
ENTRYPOINT ["/bin/packer"]
