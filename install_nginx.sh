#!/bin/bash
mkdir -p /data/src
cd /data/src
yum -y install pcre || exit 1
yum -y install openssl* || exit 1
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers make cmake || exit 1
yum -y install gd gd2 gd-devel gd2-devel || exit 1
yum install -y bison bison-devel  libxml*  || exit 1
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
ulimit -SHn 65535
tar zxvf pcre-8.36.tar.gz
test -d pcre-8.36 || /bin/rm -rfv pcre-8.36
cd pcre-8.36
./configure --prefix=/usr/local/pcre || exit 1
make  || exit 1
make install || exit 1
cd ../

tar zxvf nginx-1.5.2.tar.gz
cd nginx-1.5.2
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-pcre=/data/src/pcre-8.36 --with-http_realip_module --with-http_image_filter_module || exit 1
make || exit 1
make install || exit 1
cd ../
echo "Success to install nginx-1.5.2"
