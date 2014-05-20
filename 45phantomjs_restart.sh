#!/bin/bash
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
OUT=$(/var/app/current/phantomjs/phmon_restart.sh) || error_exit "Failed to restart PhantomJS.  $OUT" $?
echo $OUT
