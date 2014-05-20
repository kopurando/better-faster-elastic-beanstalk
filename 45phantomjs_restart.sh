#!/bin/bash
#if instance is not suited for phantom, dont run it
exec >>/var/log/cfn-init.log  2>&1

if [ -f "/etc/init/nodejs.conf" ]; then
IO_LOG_NODE=`grep IO_LOG_NODE /etc/init/nodejs.conf | cut --delimiter='"' --fields=2`
fi

if [[ $IO_LOG_NODE != *PHANTO* ]] ; then echo "Not a PHANTOMJS intsance, doing nothing, bye." && exit 0 ; fi ;
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
Echo "Restarting phantomjs heads..."
OUT=$(/var/app/current/phantomjs/phmon_restart.sh) || error_exit "Failed to restart PhantomJS.  $OUT" $?
echo $OUT
