# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

FROM mirror.gcr.io/alpine:3.24.3@sha256:b3413572228e34bd1c9245f5565e6cd127005655e8a7899aef33d8e83255c9e6

ARG TARGETARCH
ARG VERSION
ARG FRAMEWORK

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
  DOTNET_EnableDiagnostics=0 \
  SONARR__UPDATE__BRANCH=develop

USER root
WORKDIR /app

COPY --chown=0:0 --chmod=755 \
  packages/linux-musl-${TARGETARCH/amd64/x64}/${FRAMEWORK}/Sonarr/ /app/sonarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    bash \
    ca-certificates \
    catatonit \
    curl \
    icu-libs \
    jq \
    krb5-libs \
    tzdata \
    gnu-libiconv \
    file && \
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR__UPDATE__BRANCH}\nPackageVersion=${VERSION}" > /app/sonarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/*

COPY root/ /

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

EXPOSE 8989

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
