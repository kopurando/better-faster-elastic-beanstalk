#!/bin/bash
#source env variables including node version
. /opt/elasticbeanstalk/env.vars

function error_exit
{
  eventHelper.py --msg "$1" --severity ERROR
  exit $2
}

#redirect all output to cfn-init to capture it by log.io
exec >>/var/log/cfn-init.log  2>&1
#download and extract desired node.js version
echo "checking node..."
OUT=$( [ ! -d "/opt/elasticbeanstalk/node-install" ] && echo "trying to install node.js $NODE_VER"   && mkdir /opt/elasticbeanstalk/node-install ; cd /opt/elasticbeanstalk/node-install/ && \
  wget -nc http://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER-linux-$ARCH.tar.gz && \
  tar --skip-old-files -xzpf node-v$NODE_VER-linux-$ARCH.tar.gz) || error_exit "Failed to UPDATE node version. $OUT" $?.
echo $OUT


#UNCOMMENT to update npm, otherwise will be updated on instance init or rebuild
#rm -f /opt/elasticbeanstalk/node-install/npm_updated

#download & make install desired nginx version
echo "checking nginx..."

#remember to add desired modules to BOTH arch-dependent commands below:
case $( arch ) in
( i686 ) OUT=$([ ! -d "/root/nginx-$NGINX_VER" ] && echo "trying to install nginx $NGINX_VER" &>> /var/log/cfn-init.log  && \
 cd /root/ && curl --retry 10  http://nginx.org/download/nginx-$NGINX_VER.tar.gz |  tar zx && cd /root/nginx-$NGINX_VER  && \
  ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
   --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
   --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module \
   --with-http_spdy_module --with-http_realip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module \
   --with-pcre --with-debug  --with-ld-opt=' -Wl,-E' \
   --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m32 -march=i686 -mtune=pentium4 -fasynchronous-unwind-tables' &>> /var/log/cfn-init.log \
  && make &>> /var/log/cfn-init.log && make install &>> /var/log/cfn-init.log);;

( x86_64 ) OUT=$([ ! -d "/root/nginx-$NGINX_VER" ] && echo "trying to install nginx $NGINX_VER"   && \
 cd /root/ && curl --retry 10  http://nginx.org/download/nginx-$NGINX_VER.tar.gz |  tar zx && cd /root/nginx-$NGINX_VER &>> /var/log/cfn-init.log && \
  ./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \
   --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \
   --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module \
   --with-http_spdy_module --with-http_realip_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_stub_status_module \
   --with-pcre --with-debug \
   --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m64 -mtune=generic' --with-ld-opt=' -Wl,-E' &>> /var/log/cfn-init.log \
  && make &>> /var/log/cfn-init.log && make install &>> /var/log/cfn-init.log );;
esac

echo $OUT

#make sure node binaries can be found globally
if [ ! -L /usr/bin/node ]; then
  ln -s /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/node /usr/bin/node
fi

if [ ! -L /usr/bin/npm ]; then
ln -s /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm /usr/bin/npm
fi

echo "checking npm..."
if [ ! -f "/opt/elasticbeanstalk/node-install/npm_updated" ]; then
cd /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/ && /opt/elasticbeanstalk/node-install/node-v$NODE_VER-linux-$ARCH/bin/npm update npm -g
touch /opt/elasticbeanstalk/node-install/npm_updated
echo "YAY! Updated global NPM version to `npm -v`"
else
  echo "Skipping NPM -g version update. To update, please uncomment 40install_node.sh:12"
fi

