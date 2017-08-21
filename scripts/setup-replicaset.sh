#!/usr/bin/env bash

# Para obtener el directorio del script y poder referenciar los recursos absolutamente.
# Esto debido a problemas con
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done
echo "SOURCE is '$SOURCE'"
RDIR="$( dirname "$SOURCE" )"
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
if [ "$DIR" != "$RDIR" ]; then
  echo "DIR '$RDIR' resolves to '$DIR'"
fi
echo "DIR is '$DIR'"


echo "Waiting for startup.."
counter=0
until curl http://imk-mongodb1:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1; do
    printf '.'
    sleep 1

    # Verificamos si ya es lo maximo
    counter=$((counter+1))
    if [[ "$counter" -gt 360 ]]; then
        echo
        echo "Mongo server no inicio a tiempo."
        exit 1
    fi
done

echo "Waiting for Mongo startup.."
counter=0
while ! curl http://imk-mongodb1:27017/ > /dev/null 2>&1
do
    printf '.'
    sleep 1

    # Verificamos si ya es lo maximo
    counter=$((counter+1))
    if [[ "$counter" -gt 360 ]]; then
        echo
        echo "Mongo server no inicio a tiempo."
        exit 1
    fi
done
echo
echo "$(date) - Mongo Started Successfully"

echo "Waiting for Mongo 2 startup.."
counter=0
while ! curl http://imk-mongodb2:27017/ > /dev/null 2>&1
do
    printf '.'
    sleep 1

    # Verificamos si ya es lo maximo
    counter=$((counter+1))
    if [[ "$counter" -gt 360 ]]; then
        echo
        echo "Mongo 2 server no inicio a tiempo."
        exit 1
    fi
done
echo
echo "$(date) - Mongo 2 Started Successfully"

echo "Waiting for Mongo 2 startup.."
counter=0
while ! curl http://imk-mongodb3:27017/ > /dev/null 2>&1
do
    printf '.'
    sleep 1

    # Verificamos si ya es lo maximo
    counter=$((counter+1))
    if [[ "$counter" -gt 360 ]]; then
        echo
        echo "Mongo 3 server no inicio a tiempo."
        exit 1
    fi
done
echo
echo "$(date) - Mongo 3 Started Successfully"

echo curl http://imk-mongodb1:28017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started.."


echo SETUP.sh time now: `date +"%T" `
mongo --host "imk-mongodb1:27017" <<EOF

   var cfg = {
        "_id": "imolko-prod",
        "version": 1,
        "members": [
            {
                "_id": 0,
                "host": "imk-mongodb1:27017",
                "priority": 2
            },
            {
                "_id": 1,
                "host": "imk-mongodb2:27017",
                "priority": 0
            },
            {
                "_id": 2,
                "host": "imk-mongodb3:27017",
                "priority": 0
            }
        ]
    };

    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
EOF

echo