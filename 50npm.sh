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
echo "------------------------------ — Installing forever and log.io — ------------------------------------" >> /var/log/cfn-init.log
type -P forever 2>&1 && echo "... found, skipping install" >> /var/log/cfn-init.log || {
npm install -g --production forever --user 'root' &>>  /var/log/cfn-init.log
}
type -P log.io-server 2>&1 && echo "... found, skipping install" || {
npm install -g --production log.io --user 'root' &>>  /var/log/cfn-init.log
}

#install other global stuff
echo "------------------------------ — Installing other global NPM stuff (PhantomJS etc) — ------------------------------------" >> /var/log/cfn-init.log
type -P phantomjs 2>&1 && echo "... found, skipping install" >> /var/log/cfn-init.log || {
npm install -g --production phantomjs@">=1.9.6 <2.0.0" --user 'root' &>> /var/log/cfn-init.log
#npm install -g --production casperjs --user 'root'
}

#install not-installed yet app node_modules
if [ ! -d "/var/node_modules" ]; then
  mkdir /var/node_modules ;
fi
if [ -d /tmp/deployment/application ]; then
  ln -s /var/node_modules /tmp/deployment/application/
fi

if [ -f "/etc/init/nodejs.conf" ]; then
IO_LOG_NODE=`grep IO_LOG_NODE /etc/init/nodejs.conf | cut --delimiter='"' --fields=2` && sed -i.bak -e s/IO_LOG_NODE/$IO_LOG_NODE/ /root/.log.io/harvester.conf
fi

echo "------------------------------ — Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack... — -----------------------------------" >> /var/log/cfn-init.log
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install --production &>> /var/log/cfn-init.log) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT

#try restarting log.io, but if log.io is not running, start it via forever
echo "------------------------------ — Logger hiccup NOW! — ---------------------------------------" >> /var/log/cfn-init.log
if [[ `pgrep -f forever` ]]; then
  /usr/bin/forever restartall
fi
sleep 2 #make sure io-server is back up and running
if [[ ! `pgrep -f log.io-server` ]]; then
forever --minUptime 10000 start /usr/bin/log.io-server &> /var/log/io-server.log
forever --minUptime 10000 start /usr/bin/log.io-harvester &> /var/log/io-harvester.log
fi

