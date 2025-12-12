# syntax=docker/dockerfile:1

FROM docker.io/library/alpine:3.22

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
