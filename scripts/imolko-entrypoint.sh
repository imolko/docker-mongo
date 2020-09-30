#!/usr/bin/env bash

#
case "${MONGO_REPLISET}" in
    true)
        /scripts/setup-replicaset.sh >> /var/log/setup-replicaset.log 2>&1 &
    ;;

    dev-one)
        /scripts/setup-replicaset-dev-one.sh >> /var/log/setup-replicaset.log 2>&1 &
    ;;

    dev-two)
        /scripts/setup-replicaset-dev-two.sh >> /var/log/setup-replicaset.log 2>&1 &
    ;;
esac

if [ "${MONGO_DATA_SAMPLE}" == "true" ]; then
    /scripts/setup-data-sample.sh >> /var/log/setup-data-sample.log 2>&1 &
fi

exec /entrypoint.sh "$@"
