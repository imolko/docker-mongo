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


echo "Waiting for the mongos to complete the election."
counter=0
until curl http://imk-mongodb1:28017/isMaster\?text\=1  2>&1 | grep ismaster | grep true; do
    printf '.'
    sleep 1

      # Verificamos si ya es lo maximo
    counter=$((counter+1))
    if [[ "$counter" -gt 360 ]]; then
        echo "[ERROR] Mongo server repliset, no inicio a tiempo."
        exit 1
    fi
done
echo "[INFO ] The primary is elected."

echo "[INFO ] Ejecutamos el script."
mongo --host "imolko-prod/imk-mongodb1:27017,imk-mongodb2:27017,imk-mongodb3:27017" \
        aurora  \
        --quiet \
        /data-sample/aurora-db.js

