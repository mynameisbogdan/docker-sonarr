# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32

FROM mirror.gcr.io/alpine:3.24.2@sha256:31b6477333eb8257db9e5d7c3a7264fd0467928756f0bbcc27d35bea5d28cdbd

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
