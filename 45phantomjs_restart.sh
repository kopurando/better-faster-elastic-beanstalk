#!/bin/bash
#if instance is not suited for phantom, dont run it
if [[ $IO_LOG_NODE != *PHANTO* ]] ; then  exit 0 ; fi ;
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
OUT=$(/var/app/current/phantomjs/phmon_restart.sh) || error_exit "Failed to restart PhantomJS.  $OUT" $?
echo $OUT
