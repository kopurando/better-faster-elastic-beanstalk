#!/bin/bash
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
OUT=$(killall -USR2 phantom_monitor || (nohup /usr/bin/phantom_monitor -c phantom_manager_config.yml -e development >>/var/log/phantomjs/phantom_monitor.log 2>&1 &) ; exit 0;) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT
