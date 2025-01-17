#!/bin/bash
echo "Sleeping for ${SLEEP_TIME} second..."
sleep ${SLEEP_TIME};

mongodb1=$(getent hosts mongodb | awk '{ print $1 }')
mongodb2=$(getent hosts mongo2 | awk '{ print $1 }')
mongodb3=$(getent hosts mongo3 | awk '{ print $1 }')

port=${PORT:-27017}

echo "Waiting for startup.."
until curl http://${mongodb1}:27017/serverStatus\?text\=1 2>&1| grep uptime | head -1; do
  printf '.'
  sleep 1
done


echo "Started.."
echo "setup.sh; time now: $(date +"%T")"

echo curl http://${mongodb1}:27017/serverStatus\?text\=1 2>&1 | grep uptime | head -1
echo "Started.."

mongo --host ${mongodb1}:${port} <<EOF
   var cfg = {
        "_id": "rs0",
        "members": [
            {
                "_id": 0,
                "host": "${mongodb1}:${port}",
                "priority":1
            },
            {
                "_id": 1,
                "host": "${mongodb2}:${port}",
                "priority":0.5
            },
            {
                "_id": 2,
                "host": "${mongodb3}:${port}",
                "priority":0.5
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
    rs.status();
EOF
