#!/bin/bash
#get env vars from EB app container and inject them here. Run as cron-node.sh cron-app.js
eval "$(grep -E '^env [A-Za-z0-9_-]+="[^"]+"$' /etc/init/nodejs.conf |  sed 's/env /export /g')"
export CRON_NODE_COMMAND="node $1"
cd /var/app/current
exec su -s /bin/sh -c 'PATH=$PATH:$NODE_HOME/bin $CRON_NODE_COMMAND 2>&1' nodejs >> /var/log/cron
