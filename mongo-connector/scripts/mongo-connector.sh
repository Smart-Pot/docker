#!/bin/bash

MONGO=$(getent hosts mongodb | awk '{ print $1 }')
ELASTIC=$(getent hosts elasticsearch | awk '{ print $1 }')

echo ${ELASTIC}

pip install mongo-connector
pip install elastic2-doc-manager[elastic5]

printf "\n Waiting for mongodb \n"
until curl http://${MONGO}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1;do
    printf "."
    sleep 1
done
echo "mongo started"

mongo-connector --logfile=/var/scripts/mongo-connector.log --auto-commit-interval=5 -m ${MONGO}:27017 -t ${ELASTIC}:9200 -d elastic2_doc_manager -n smart-pot.posts -g smart-pot_opt.posts