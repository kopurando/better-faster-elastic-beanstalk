#!/bin/bash
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
OUT=$(/var/app/current/phantom_monitor_restart.sh) || error_exit "Failed to run npm install.  $OUT" $?
echo $OUT
