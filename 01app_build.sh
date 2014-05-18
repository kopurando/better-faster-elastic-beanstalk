#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#redirect all output to cfn-init to capture it by log.io
exec >>/var/log/cfn-init.log  2>&1
echo "------------------------------ — Logger hiccup NOW! — ---------------------------------------"

if [ -f "/tmp/deployment/application/public/build.js" ]; then
echo "compiling underscore templates..."
cd /tmp/deployment/application && /usr/bin/jade /tmp/deployment/application/views/underscore/*.jade --out /tmp/deployment/application/public/templates >> /var/log/cfn-init.log
echo "running r.js build....."
OUT=$(cd /tmp/deployment/application/public && /usr/bin/r.js -o build.js >> /var/log/cfn-init.log && mv -v /tmp/deployment/application/public/dist /tmp/deployment/application/dist && rm -rf /tmp/deployment/application/public/ && mv -v /tmp/deployment/application/dist /tmp/deployment/application/public ) || error_exit "Failed to run r.js optimizer. $OUT" $?
echo $OUT
echo "computing md5 hashes...."
cd /tmp/deployment/application/public/ && find . -maxdepth 3 -type f  -iname '*js' -o -iname '*css' -type f | xargs  md5sum | awk '{system("echo "$1" > "$2".md5")}'
echo "gzipping everything!"
cd /tmp/deployment/application/public/ && find . -type f -iname "*css" -o -iname "*js" -type f  | while read -r x;do   gzip -9 -c "$x" > "$x.gz";done
echo "touching all files to make them dated with the same time (as per nginx gzip_static recommendation)"
cd /tmp/deployment/application/public/ && find . -type f -exec touch {} \;
fi
