#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#redirect all output to cfn-init to capture it by log.io
exec >>/var/log/cfn-init.log  2>&1
echo "------------------------------ — Logger hiccup NOW! — ---------------------------------------"
/sbin/stop io-server
/sbin/stop io-harvester

#avoid long NPM fetch hangups
npm config set fetch-retry-maxtimeout 15000
#if log.io is not installed, install it and forever.js
# do not install forever, as we moved services to /etc/init to decrease RAM footprint
# type -P forever  && echo "... found, skipping install"  || npm install -g --production forever --user 'root'
type -P log.io-server  && echo "... found, skipping install"   || npm install -g --production log.io --user 'root'

if [ -f "/etc/init/nodejs.conf" ]; then
IO_LOG_NODE=`grep IO_LOG_NODE /etc/init/nodejs.conf | cut --delimiter='"' --fields=2` && sed -i.bak -e s/IO_LOG_NODE/$IO_LOG_NODE/ /root/.log.io/harvester.conf
fi

if [[ ! `pgrep -f log.io-server` ]]; then
/sbin/start io-server
sleep 2
/sbin/start io-harvester
echo "done"
fi

#install other global stuff
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

echo "------------------------------ — Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack... — -----------------------------------"
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install --production) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT

chmod -R o+r /var/node_modules
