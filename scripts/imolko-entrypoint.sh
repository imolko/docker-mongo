#!/usr/bin/env bash

#
if [ "${MONGO_REPLISET}" == "true" ]; then
    /scripts/setup-replicaset.sh >> /var/log/setup-replicaset.log 2>&1 &
fi

if [ "${MONGO_DATA_SAMPLE}" == "true" ]; then
    /scripts/setup-data-sample.sh >> /var/log/setup-data-sample.log 2>&1 &
fi

exec /entrypoint.sh "$@"
