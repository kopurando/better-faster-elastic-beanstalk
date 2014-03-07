#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#if log.io is not installed, install it and forever.js
if [ ! -f "/usr/bin/log.io-server" ]; then
npm install -g forever --user 'root'
npm install -g log.io --user 'root'
fi

echo "Logger hiccup NOW!"
#try restarting log.io, but if log.io is not running, start it via forever
if [[ `pgrep -f forever` ]]; then
  /usr/bin/forever restartall
fi
sleep 2 #make sure io-server is back up and running
if [[ ! `pgrep -f log.io-server` ]]; then
forever --minUptime 10000 start /usr/bin/log.io-server &> /var/log/io-server.log
forever --minUptime 10000 start /usr/bin/log.io-harvester &> /var/log/io-harvester.log
fi

#install not-installed yet app node_modules
if [ ! -d "/var/node_modules" ]; then
  mkdir /var/node_modules ;
fi
if [ -d /tmp/deployment/application ]; then
  ln -s /var/node_modules /tmp/deployment/application/
fi
chmod +x /tmp/deployment/application/*.sh
npm config set fetch-retry-maxtimeout 15000
echo "Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack..."
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install 2>&1) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT
