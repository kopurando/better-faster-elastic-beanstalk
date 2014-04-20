#!/bin/bash

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#configs can't be moved from enf.conf as ebnode.py overwrites dir after YML has been processed
#mv -vf /tmp/deployment/config/#etc#nginx#conf.d#00_elastic_beanstalk_proxy.conf /etc/nginx/conf.d/00_elastic_beanstalk_proxy.conf >> /var/log/cfn-init.log
#mv -vf /opt/elasticbeanstalk/*.snippet /etc/nginx/conf.d/ >> /var/log/cfn-init.log
echo "Testing nginx config.... " >> /var/log/cfn-init.log
#test nginx config before proceeding with restart
OUT=$(/usr/sbin/nginx -tc /etc/nginx/nginx.conf && /opt/elasticbeanstalk/containerfiles/ebnode.py --action stop-all 2>&1) || error_exit "Failed to stop service daemons, CHECK NGINX CONFIG $OUT" $?
echo $OUT
