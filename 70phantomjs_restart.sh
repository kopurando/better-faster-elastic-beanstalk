#!/bin/bash
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
OUT=$(nohup killall -USR2 phantom_monitor || cd /var/app/current/phantomjs && /usr/bin/phantom_monitor -c phantom_manager_config.yml -e development >>/var/log/phantomjs/phantom_monitor.log 2>&1 &) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT
echo "did my best"
