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

echo "------------------------------ — Installing/updating NPM modules, it might take a while, go take a leak or have a healthy snack... — -----------------------------------" >> /var/log/cfn-init.log
OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm install --production &>> /var/log/cfn-init.log) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT

