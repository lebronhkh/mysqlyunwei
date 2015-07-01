#!/bin/bash

for pkg in  autoconf automake libtool libtool-ltdl libtool-ltdl-devel flex bison bison-devel libxml2 libxml2-devel libcurl-devel \
                libjpeg-turbo-devel libpng-devel freetype-devel boost-devel libmcrypt libmcrypt-devel re2c mingw32-iconv mingw32-iconv-static \
                libevent libevent-devel memcached memcached-devel libmemcached libmemcached-devel ;do
    rpm -q $pkg || pkgs="$pkgs $pkg"
done
[ -n "$pkgs" ] && yum install -y $pkgs
processorcount=`awk '/processor/{c+=1}END{print c}' /proc/cpuinfo`
install_php() {
    [ -x /usr/local/php/bin/php ] && echo "php-5.5.13 has been installed on this machine" && return 1
    cd /data/src
    [ -d php-5.5.13 ] && rm -rf php-5.5.13
    tar xvf php-5.5.13.tar.bz2 || { echo "failed to untar php-5.5.13.tar.bz2";exit 1; }
    cd php-5.5.13
    CHOST="x86_64-pc-linux-gnu" CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" ./configure \
    --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd \
    --with-iconv-dir=/usr/i686-pc-mingw32/sys-root/mingw --with-freetype-dir --with-jpeg-dir --with-png-dir --enable-zip --with-zlib \
    --with-gd--disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --with-curl --enable-mbstring --with-mcrypt --disable-ipv6 \
    --enable-static --enable-maintainer-zts --enable-sockets --enable-soap --with-openssl --without-pdo-sqlite --with-gettext --enable-fpm || exit 1
    sed -i 's/CC = gcc/CC = gcc -fPIC/g' Makefile 
    make -j $processorcount || exit 1
    make install || exit 1
    cd ..
}
install_memcache(){
    /usr/local/php/bin/php -m | grep 'memcache'
    [ $? -eq 0 ] && return 1
    cd /data/src
    tar zxvf memcache-2.2.7.tgz || { echo "failed to untar memcache-2.2.7.tgz";exit 1; }
    cd memcache-2.2.7/
    /usr/local/php/bin/phpize || { echo "phpize failed when install memcache";exit 1; }
    ./configure --enable-memcache --with-zlib-dir --with-php-config=/usr/local/php/bin/php-config || exit 1
    make -j $processorcount || exit 1
    make install || exit 1
    cd ../
    sed -i -e "/extension = \"memcache.so\"/ d" -e"/extension_dir = \"ext\"/a extension = \"memcache.so\"" /usr/local/php/etc/php.ini
    echo "Success install memcache-2.2.7 extension for php-5.5.13 on this machine"
    cd ..
}
install_xdebug(){
    /usr/local/php/bin/php -m | grep 'xdebug'
    [ $? = 0 ] && return 1
    cd /data/src/
    tar xvf xdebug-2.2.5.tgz || { echo "failed to untar xdebug-2.2.5.tgz";exit 1; }
    cd xdebug-2.2.5/
    /usr/local/php/bin/phpize || { echo "phpize failed when install xdebug for php";exit 1; }
    CHOST="x86_64-pc-linux-gnu" CFLAGS="-O3" CXX=gcc CXXFLAGS="-O3 -felide-constructors -fno-exceptions -fno-rtti" ./configure \
    --enable-xdebug --with-php-config=/usr/local/php/bin/php-config || exit 1
    make -j $processorcount || exit 1
    make install || exit 1
    sed -i "/^; extension_dir = \"ext\"$/a Zend_extension = \"xdebug.so\"" /usr/local/php/etc/php.ini
    cd ..
}
install_opcache(){
    /usr/local/php/bin/php -m | grep 'Zend OPcache'
    [ $? = 0 ] && return 1
    cd /data/src
    tar xvf zendopcache-7.0.2.tgz  || { echo "failed to untar zendopcache-7.0.2.tgz";exit 1; }
    cd zendopcache-7.0.2
    /usr/local/php/bin/phpize || { echo "phpize failed when install zendopcache-7.0.2";exit 1; }
    ./configure --with-php-config=/usr/local/php/bin/php-config || exit 1
    make || exit 1
    make install || exit 1
    sed -i "/^\[opcache\]/ i zend_extension=opcache.so" /usr/local/php/etc/php.ini
    sed -i -e "/^\[opcache\]/ a\
opcache.memory_consumption=128\n\
opcache.interned_strings_buffer=8\n\
opcache.max_accelerated_files=4000\n\
opcache.revalidate_freq=60\n\
opcache.fast_shutdown=1\n\
opcache.enable=1\n\
opcache.enable_cli=1" /usr/local/php/etc/php.ini
    echo "Success to install zendopcache extension for php-5.5.26 on this macine"
    cd ..
}
install_php
install_memcache
install_xdebug
install_opcache
