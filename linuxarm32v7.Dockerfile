FROM arm32v6/alpine:3.8

LABEL maintainer="Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)"

ENV DEBUG=false \
    DOCKER_HOST=unix:///var/run/docker.sock
#EnableQEMU COPY qemu-arm-static /usr/bin

# Install packages required by the image
RUN apk add --update \
        bash \
        ca-certificates \
        curl \
        jq \
        openssl \
    && rm /var/cache/apk/*

# Install simp_le
COPY /install_simp_le.sh /app/install_simp_le.sh
RUN chmod +rx /app/install_simp_le.sh \
    && sync \
    && /app/install_simp_le.sh \
    && rm -f /app/install_simp_le.sh

COPY /app/ /app/

WORKDIR /app

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
