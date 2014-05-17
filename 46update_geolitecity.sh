 #!/bin/bash
 function error_exit
 {
   eventHelper.py --msg "$1" --severity ERROR
   exit $2
 }
 exec >>/var/log/cfn-init.log  2>&1
 [ ! -f "/var/GeoLiteCity.dat" ] && echo "GeoLiteCity.dat not found, fetching new one..."  && cd /var/ && curl --retry 10 http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz | zcat > /var/GeoLiteCity.new && mv -vf /var/GeoLiteCity.new /var/GeoLiteCity.dat

 OUT=$(cp -vf /var/GeoLiteCity.dat /var/app/current/geolite_data/GeoLiteCity.dat) || error_exit "Failed to fetch/1update GeoLiteCity.dat  $OUT" $?
 echo $OUT
