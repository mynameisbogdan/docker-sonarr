#!/usr/bin/env bash

exec \
    /app/sonarr/bin/Sonarr \
        --nobrowser \
        --data=/config \
        "$@"
