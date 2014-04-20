#!/bin/bash

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

echo "Testing nginx config.... " >> /var/log/cfn-init.log
#test nginx config before proceeding with restart
OUT=$(/usr/sbin/nginx -tc /etc/nginx/nginx.conf && /opt/elasticbeanstalk/containerfiles/ebnode.py --action stop-all 2>&1) || error_exit "Failed to stop service daemons, CHECK NGINX CONFIG $OUT" $?
echo $OUT
