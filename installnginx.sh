#!/bin/bash

#need nginx(start-stop script)  nginx-1.6.0.tar.gz  nginx.conf

test -x /usr/local/nginx/sbin/nginx && echo "nginx-1.6.0 has been installed on this machine" && exit 1
test ! -d /data/src && mkdir -p /data/src
cd /data/src
yum -y install pcre || exit 1
yum -y install openssl* || exit 1
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers make cmake pcre pcre-devel gperftools|| exit 1
yum -y install gd gd2 gd-devel gd2-devel || exit 1
yum install -y bison bison-devel  libxml*  || exit 1
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
ulimit -SHn 65535
processorcount=`awk '/processor/{c++}END{print c}' /proc/cpuinfo`
#tar zxvf pcre-8.36.tar.gz || { echo "failed to untar pcre-8.36.tar.gz";exit 1; }
#test -d pcre-8.36 || /bin/rm -rfv pcre-8.36
#cd pcre-8.36
#./configure --prefix=/usr/local/pcre || exit 1
#make  || exit 1
#make install || exit 1
#cd ../
test -d nginx-1.6.0 && /bin/rm -rf nginx-1.6.0
tar zxvf nginx-1.6.0.tar.gz || { echo "failed to untar nginx-1.6.0.tar.gz";exit 1; }
cd nginx-1.6.0
sed -i 's#CFLAGS=\"\$CFLAGS -g\"#CFLAGS=\"\$CFLAGS \"#' auto/cc/gcc
#sed -r -i -e "s@(Google perftools in) /usr/local@\1 /usr@" ./auto/lib/google-perftools/conf \
#          -e "s@(ngx_feature_libs=\"-R)(/usr)/local/lib (-L/usr)/local/lib@\1\2\3@" \
#          -e "s@(ngx_feature_libs=\"-L/usr)/local/lib@\1@" || { echo "failed on redefine google gperftool";exit 1; }
CHOST="x86_64-pc-linux-gnu" CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" ./configure --user=www --group=www \
    --prefix=/usr/local/nginx --with-http_stub_status_module  --with-pcre --with-http_ssl_module --with-http_image_filter_module \
    --with-http_realip_module || exit 1
sed -i 's/CC = gcc/CC = gcc -fPIC/g' Makefile  
make -j $processorcount || exit 1
make install || exit 1
#./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/data/src/pcre-8.36 --with-http_realip_module --with-http_image_filter_module || exit 1
#make || exit 1
#make install || exit 1
cd ../
if [ -s /data/src/nginx.conf ];then
    cp -af /data/src/nginx.conf /usr/local/nginx/conf/
    cpus=""
    for cpunum in `seq $processorcount`;do
        cpu=`gawk -v n=$processorcount -v c=$cpunum 'BEGIN{ for(i=1;i<=n;i++) { if(i!=c)printf 0;else printf 1; } }'`
        cpus="$cpu $cpus"
    done
    sed -r -i -e "s/(^worker_processes).*;/\1 $processorcount;/" -e "s/(^worker_cpu_affinity).*;/\1 $cpus;/" /usr/local/nginx/conf/nginx.conf
else
    echo "/data/src/nginx.conf does not exist,so use default"
fi
test -s /data/src/nginx && cp -af /data/src/nginx /etc/init.d/ && chmod a+x /etc/init.d/nginx
echo "Success to install nginx-1.6.0"
