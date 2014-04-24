#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#redirect all output to cfn-init to capture it by log.io
exec >>/var/log/cfn-init.log  2>&1
#avoid long NPM fetch hangups
npm config set fetch-retry-maxtimeout 15000
#if log.io is not installed, install it and forever.js
echo "------------------------------ — Installing log.io — ------------------------------------"
# do not install forever, as we moved services to /etc/init to decrease RAM footprint
# type -P forever  && echo "... found, skipping install"  || npm install -g --production forever --user 'root'
type -P log.io-server  && echo "... found, skipping install"   || npm install -g --production log.io --user 'root'

#install other global stuff
echo "------------------------------ — Installing other global NPM stuff (PhantomJS, RequireJS, jade etc) — ------------------------------------"
type -P phantomjs  && echo "... found, skipping install"  || {
npm install -g --production phantomjs@">=1.9.6 <2.0.0" --user 'root'
#npm install -g --production casperjs --user 'root'
}
type -P r.js  && echo "... found, skipping install"   || npm install -g --production requirejs@">=2.1.11 <3.0.0" --user 'root'
type -P jade  && echo "... found, skipping install"   || npm install -g --production jade@">=1.3.1 <2.0.0" --user 'root'

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

echo "------------------------------ — Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack... — -----------------------------------"
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install --production) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT

#try restarting log.io, but if log.io is not running, start it via forever
# /sbin/stop io-server
# /sbin/stop io-harvester
# sleep 1 #make sure io-server is down
if [[ ! `pgrep -f log.io-server` ]]; then
echo "------------------------------ — Logger hiccup NOW! — ---------------------------------------"
/sbin/start io-server
/sbin/start io-harvester
echo "done"
fi
# if [[ `pgrep -f forever` ]]; then
#   /usr/bin/forever restartall
# fi
# if [[ ! `pgrep -f log.io-server` ]]; then
# forever --minUptime 10000 start /usr/bin/log.io-server &> /var/log/io-server.log
# forever --minUptime 10000 start /usr/bin/log.io-harvester &> /var/log/io-harvester.log
# fi

