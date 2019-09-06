# Use manifest image which support all architecture
FROM debian:stretch-slim as builder
LABEL maintainer="Jason Wilder <mail@jasonwilder.com>"

RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends ca-certificates wget

ENV VERSION 0.7.4
ENV DOWNLOAD_URL https://github.com/jwilder/docker-gen/releases/download/$VERSION/docker-gen-alpine-linux-armhf-$VERSION.tar.gz
ENV BIN_SHA256 5423b7a4c3f36102fdb7dbc2cf1bcf7fcc5ebb296456b2d48aed0fc3c5d7883a

RUN mkdir /tmp/bin && \
    wget -qO docker-gen.tar.gz $DOWNLOAD_URL && \
    echo "$BIN_SHA256 docker-gen.tar.gz" | sha256sum -c - && \
    tar -xzvf docker-gen.tar.gz -C /tmp/bin

FROM arm32v6/alpine:3.9

LABEL maintainer="Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)"
COPY --from=builder "/tmp/bin" /usr/local/bin

ENV DEBUG=false \
    DOCKER_HOST=unix:///var/run/docker.sock
#EnableQEMU COPY qemu-arm-static /usr/bin

# Install packages required by the image
RUN apk add --update \
        bash \
        ca-certificates \
        coreutils \
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
