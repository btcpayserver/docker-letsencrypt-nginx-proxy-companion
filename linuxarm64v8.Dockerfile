# Use manifest image which support all architecture
FROM golang:1.12-stretch as builder

ENV VERSION 0.7.4

WORKDIR /go/src/github.com/jwilder/docker-gen
RUN git clone https://github.com/jwilder/docker-gen . && git checkout 4edc190faa34342313589a80e3a736cafb45919b

RUN make get-deps

RUN mkdir -p dist/linux/arm64 && GOOS=linux GOARCH=arm64 go build -o dist/linux/arm64/docker-gen ./cmd/docker-gen

RUN apt-get update && apt-get install -y --no-install-recommends qemu qemu-user-static qemu-user binfmt-support

FROM arm64v8/alpine:3.9

COPY --from=builder /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64-static
COPY --from=builder "/go/src/github.com/jwilder/docker-gen/dist/linux/arm64/docker-gen" /usr/local/bin/docker-gen

ENV DEBUG=false \
    DOCKER_HOST=unix:///var/run/docker.sock

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
