# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG VERSION
ARG SONARR_RELEASE
ARG SONARR_BRANCH="develop"

LABEL build_version=$VERSION
LABEL maintainer="nobody"

# environment settings
ENV XDG_CONFIG_HOME="/config/xdg"

COPY build/_artifacts/linux-musl-x64/net6.0/Sonarr/ /app/sonarr/bin

RUN set -eux && \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    xmlstarlet && \
  echo "**** install sonarr ****" && \
  mkdir -p /app/sonarr/bin && \
  echo -e "UpdateMethod=docker\nBranch=${SONARR_BRANCH}\nPackageVersion=${VERSION}" > /app/sonarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/sonarr/bin/Sonarr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 8989

VOLUME /config
