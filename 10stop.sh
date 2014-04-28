#!/bin/bash
exec >>/var/log/cfn-init.log  2>&1

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#in order to test, config should be moved at this step as ebnode.py overwrites config after YML has been processed, and that can lead to nginx start failure
mv -vf /tmp/deployment/config/#etc#nginx#conf.d#00_elastic_beanstalk_proxy.conf /etc/nginx/conf.d/00_elastic_beanstalk_proxy.conf

echo "Testing nginx config.... "
#test nginx config before proceeding with restart
OUT=$(/usr/sbin/nginx -tc /etc/nginx/nginx.conf && /opt/elasticbeanstalk/containerfiles/ebnode.py --action stop-all 2>&1) || error_exit "Failed to stop service daemons, CHECK NGINX CONFIG $OUT" $?
echo $OUT
