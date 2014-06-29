#!/bin/bash
. /opt/elasticbeanstalk/env.vars
function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#redirect all output to cfn-init to capture it by log.io
exec >>/var/log/cfn-init.log  2>&1
echo ">>>> Running r.js......"

if ls /tmp/deployment/application/public/build*js &> /dev/null; then
echo "compiling underscore templates..."
cd /tmp/deployment/application && cp -r views/underscore public/templates && jade public/templates/ && find public/templates/ -name "*jade" -delete >> /var/log/cfn-init.log
OUT=$(cd /tmp/deployment/application/public && r.js -o build_desktop.js  >> /var/log/cfn-init.log && r.js -o build_mobile.js >> /var/log/cfn-init.log && rm -rf /tmp/deployment/application/public/ && mv -v /tmp/deployment/application/dist /tmp/deployment/application/public ) || error_exit "Failed to run r.js optimizer. $OUT" $?
echo $OUT
echo "computing md5 hashes...."
cd /tmp/deployment/application/public/ && find . -maxdepth 3 -type f  -iname '*js' -o -iname '*css' -type f | xargs  md5sum | awk '{system("echo "$1" > "$2".md5")}'
echo "gzipping everything!"
cd /tmp/deployment/application/public/ && find . -type f -iname "*css" -o -iname "*js" -type f  | while read -r x;do   gzip -9 -c "$x" > "$x.gz";done
echo "touching all files to make them dated with the same time (as per nginx gzip_static recommendation)"
cd /tmp/deployment/application/public/ && find . -type f -exec touch {} \;
fi
