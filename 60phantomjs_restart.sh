killall -USR2 phantom_monitor || cd /var/app/current/phantomjs && /usr/bin/phantom_monitor -c phantom_manager_config.yml -e development >>/var/log/phantomjs/phantom_monitor.log 2>&1 &
