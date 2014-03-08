#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#avoid long NPM fetch hangups
npm config set fetch-retry-maxtimeout 15000

#if log.io is not installed, install it and forever.js
if [ ! -f "/usr/bin/log.io-server" ]; then
echo "Installing forever and log.io"
npm install -g forever --user 'root'
npm install -g log.io --user 'root'
fi
echo "Installing other global NPM stuff (PhantomJS etc)"
npm install -g phantomjs --user 'root'
#npm install -g casperjs --user 'root'

#install not-installed yet app node_modules
if [ ! -d "/var/node_modules" ]; then
  mkdir /var/node_modules ;
fi
if [ -d /tmp/deployment/application ]; then
  ln -s /var/node_modules /tmp/deployment/application/
fi

#make any in-app shell scripts executable
chmod +x /tmp/deployment/application/*.sh

echo "Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack..."
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install 2>&1) || error_exit "Failed to run npm install.  $OUT" $?

echo "Logger hiccup NOW!"
#try restarting log.io, but if log.io is not running, start it via forever


echo $OUT
