#!/bin/bash
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}
STAMP=`date +%m%d_%H%M`
mkdir /var/app_$STAMP;
mv /var/app/current /var/app_$STAMP/current;
rm -rf /var/app/
