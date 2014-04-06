#!/bin/bash

#try restarting log.io, but if log.io is not running, start it via forever
echo "------------------------------ — Logger hiccup NOW! — ---------------------------------------" >> /var/log/cfn-init.log
if [[ `pgrep -f forever` ]]; then
  /usr/bin/forever restartall
fi
sleep 2 #make sure io-server is back up and running
if [[ ! `pgrep -f log.io-server` ]]; then
forever --minUptime 10000 start /usr/bin/log.io-server &> /var/log/io-server.log
forever --minUptime 10000 start /usr/bin/log.io-harvester &> /var/log/io-harvester.log
fi
sleep 3 #make sure io-server is back up and running
echo "DONE." >> /var/log/cfn-init.log
