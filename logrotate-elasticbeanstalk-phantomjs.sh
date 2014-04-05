#!/bin/sh
test -x /usr/sbin/logrotate || exit 0
/usr/sbin/logrotate -f /etc/logrotate.conf.phantomjs.elasticbeanstalk
