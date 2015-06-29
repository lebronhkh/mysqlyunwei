#!/bin/bash

#yum install -y bison bison-devel  libxml*  || exit 1
install_from_source() {
    #[ $# -lt 2 ] || exit 1
    local sourcetar=$1
    local prefix=$2
    shift 2
    #test -d "${prefix}" && echo "$sourcetar has been installed on this machine" && return 0
    cd /data/src || exit 1
    local tardir=`tar -tf $sourcetar | awk 'NR==1'`
    test  -e $sourcetar || { echo "$sourcetar does not exist";exit 1; }
    test -d $tardir && /bin/rm -rfv $tardir
    tar xvf $sourcetar || { echo "Failed to untar $sourcetar";exit 1; } 
    cd $tardir || exit 1
    ./configure --prefix=$prefix $@ || exit 1
    make || exit 1
    make install || exit 1
    cd ..
    echo "Success install $sourcetar" `date "+%Y-%m-%d %H:%M:%S"` >> /tmp/lnmp.log
}
install_soft(){
    cd /usr/local/src || exit 1
    test ! -e freetype-2.4.8.tar.gz || { echo "freetype-2.4.8.tar.gz does not exist";exit 1; }
    test -d freetype-2.4.8 && /bin/rm -rfv freetype-2.4.8
    tar xvf freetype-2.4.8.tar.gz || { echo "Failed to untar freetype-2.4.8.tar.gz";exit 1; }
    cd freetype-2.4.8 || exit 1
    ./configure --prefix=/usr/local/freetype || exit 1
    make || exit 1
    make install || exit 1
    cd ..

    test ! -e libpng-1.5.5.tar.gz || { echo "libpng-1.5.5.tar.gz does not exist";exit 1; }
    test -d libpng-1.5.5 && /bin/rm -rfv libpng-1.5.5
    tar xvf libpng-1.5.5.tar.gz || { echo "Failed to untar libpng-1.5.5.tar.gz";exit 1; } 
    cd libpng-1.5.5 || exit 1
    ./configure --prefix=/usr/local/libpng || exit 1
    make || exit 1
    make install || exit 1
    cd ..

    test ! -e jpegsrc.v8c.tar.gz || { echo "jpegsrc.v8c.tar.gz does not exist";exit 1; }
    test -d jpeg-8c && /bin/rm -rfv jpeg-8c
    tar xvf  jpegsrc.v8c.tar.gz || { echo "Failed to untar jpegsrc.v8c.tar.gz";exit 1; }
    cd jpeg-8c
    mkdir -p /usr/local/jpeg
    mkdir -p /usr/local/jpeg/bin
    mkdir -p /usr/local/jpeg/lib
    mkdir -p /usr/local/jpeg/include
    mkdir -p /usr/local/jpeg/man
    mkdir -p /usr/local/jpeg/man1
    ./configure --prefix=/usr/local/jpeg --enable-shared --enable-static || exit 1
    make || exit 1
    make install || exit 1
    cd ..

    test ! -e libmcrypt-2.5.8.tar.gz || { echo "libmcrypt-2.5.8.tar.gz does not exist";exit 1; }
    test -d libmcrypt-2.5.8 && /bin/rm -rfv libmcrypt-2.5.8
    tar xvf libmcrypt-2.5.8.tar.gz || { echo "Failed to untar libmcrypt-2.5.8.tar.gz";exit 1; }
    cd libmcrypt-2.5.8
    ./configure --prefix=/usr/local/libmcrypt || exit 1
    make || exit 1
    make install || exit 1
    cd ..
}
install_mhash(){  
    cd /data/src
    test  -e mhash-0.9.9.9.tar.gz || { echo "mhash-0.9.9.9.tar.gz does not exist";exit 1; }  
    test -d mhash-0.9.9.9 && /bin/rm -rfv mhash-0.9.9.9
    tar xvf mhash-0.9.9.9.tar.gz || { echo "Failed to untar mhash-0.9.9.9.tar.gz";exit 1; }
    cd mhash-0.9.9.9
    ./configure || exit 1
    make || exit 1
    make install || exit 1
    cd ..

}

install_php() {
    yum -y install gdbm gdbm-devel libtool libmcrypt libmcrypt-devel
    [ $? -ne 0 ] && echo "install dependent pkg for php failed" && exit 1
    cd /data/src 
    test !  -e php-5.5.26.tar.bz2 && echo "php-5.5.26.tar.bz2 does not exist" && exit 1
    test -d php-5.5.26 && /bin/rm -rfv php-5.5.26
    tar xvf php-5.5.26.tar.bz2 || exit 1
    cd php-5.5.26
    export LIBS="-lm -ltermcap -lresolv"
    export DYLD_LIBRARY_PATH="/usr/local/mysql/lib/:/lib/:/usr/lib/:/usr/local/lib:/lib64/:/usr/lib64/:/usr/local/lib64"
    export LD_LIBRARY_PATH="/usr/local/mysql/lib/:/lib/:/usr/lib/:/usr/local/lib:/lib64/:/usr/lib64/:/usr/local/lib64"
    #./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql \
    #  --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir --with-freetype-dir=/data/apps/libs --with-jpeg-dir=/data/apps/libs \
    #  --with-png-dir=/data/apps/libs --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop \
    #  --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt=/data/apps/libs \
    #  --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap \
    #  --enable-opcache --with-pdo-mysql --enable-maintainer-zts || exit 1
    cp -frp /usr/lib64/libldap* /usr/lib/
    ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-gdbm=/usr/lib --with-gd=/usr/local \
      --enable-gd-native-ttf --enable-gd-jis-conv --with-freetype-dir=/data/apps/libs --with-jpeg-dir=/data/apps/libs --with-png-dir=/data/apps/libs \
      --with-zlib --with-mhash --enable-sockets --enable-ftp --with-libxml-dir --enable-xml --disable-rpath --enable-bcmath --enable-shmop \
      --enable-sysvsem --enable-inline-optimization --with-curl  --enable-mbregex  --enable-fpm --enable-mbstring --with-mcrypt \
      --with-openssl --with-mhash --enable-pcntl   --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap --with-pear  \
      --enable-pdo --with-pdo-mysql --with-gettext --enable-exif --enable-wddx --enable-calendar  --enable-dba --enable-sysvmsg  --enable-sysvshm \
      --enable-debug --enable-embed --with-pcre-regex  --with-pdo-mysql --enable-maintainer-zts --enable-opcache=no \
      --with-mysqli=/usr/local/mysql/bin/mysql_config  --with-iconv-dir || exit 1
    make || exit 1
    make install || exit 1
    cp -v php.ini-development /usr/local/php/etc/php.ini
    ln -sv /usr/local/mysql/lib/libmysqlclient.18.dylib /usr/lib/libmysqlclient.18.dylib
    mv /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
    cd ..
    echo "Success install php-5.5.26 on this machine"
    #cd /usr/local/php/bin
    #./pecl install memcache || { echo "failed to install php extension memcache";exit 1; }
    #sed -i -e "/extension = \"memcache.so\"/ d" -e"/extension_dir = \"ext\"/a extension = \"memcache.so\"" /usr/local/php/etc/php.ini
    #echo "Success to install memcache extension for php"
}
install_memcache(){
    cd /data/src
    tar xvf autoconf-latest.tar.gz || { echo "failed to untar autoconf-latest.tar.gz";exit 1; }
    cd autoconf-2.69/
    ./configure --prefix=/data/apps/libs || exit 1
    make || exit 1
    make install || exit 1
    cd ..

    tar zxvf memcache-2.2.7.tgz || { echo "failed to untar memcache-2.2.7.tgz";exit 1; }
    cd memcache-2.2.7/
    export PHP_AUTOCONF="/data/apps/libs/bin/autoconf"
    export PHP_AUTOHEADER="/data/apps/libs/bin/autoheader"
    /usr/local/php/bin/phpize || { echo "phpize failed when install memcache";exit 1; }
    ./configure --enable-memcache --with-zlib-dir --with-php-config=/usr/local/php/bin/php-config || exit 1
    make || exit 1
    make install || exit 1
    cd ../
    sed -i -e "/extension = \"memcache.so\"/ d" -e"/extension_dir = \"ext\"/a extension = \"memcache.so\"" /usr/local/php/etc/php.ini
    echo "Success install memcache-2.2.7 extension for php-5.5.26 on this machine"
}
install_eaccelerator(){
    cd /data/src
    tar xvf eaccelerator-0.9.6.1.tar.bz2 || { echo "failed to untar eaccelerator.0.9.6.1.tar.bz2";exit 1; }
    cd eaccelerator-0.9.6.1/
    /usr/local/php/bin/phpize || { echo "phpize failed when install eaccelerator-0.9.6.1";exit 1; }
    ./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config || exit 1
    make || { echo "make error on eaccelerator";exit 1; }
    make install || exit 1
    cp control.php /usr/local/nginx/html
    cd ..
    echo "Success install eaccelerator-0.9.6.1 extension for php-5.5.26 on this machine"
    if ! grep -q "[eaccelerator]" /etc/local/php/etc/php.ini ;then
        echo '[eaccelerator]
        eaccelerator.allowed_admin_path = "/usr/local/nginx/html"
        zend_extension="/usr/local/php/lib/php/extensions/debug-zts-20121212/eaccelerator.so"
        eaccelerator.shm_size="8"
        eaccelerator.cache_dir="/tmp/eaccelerator_cache"
        eaccelerator.enable="1"
        eaccelerator.optimizer="1"
        eaccelerator.check_mtime="1"
        eaccelerator.debug="0"
        eaccelerator.filter=""
        eaccelerator.shm_max="0"
        eaccelerator.shm_ttl="3600"
        eaccelerator.shm_prune_period="3600"
        eaccelerator.shm_only="0"
        eaccelerator.compress="1"
        eaccelerator.compress_level="9"
        eaccelerator.keys = "disk_only"
        eaccelerator.sessions = "disk_only"
        eaccelerator.content = "disk_only"' >> /usr/local/php/etc/php.ini
    fi
    mkdir -p /tmp/accelerator_cache
    chmod -R 777 /tmp/accelerator_cache
    echo "Success to install eaccelerator.0.9.6.1 extension for php-5.5.26 on this machine"

}
install_opcache(){
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
}
mkdir -p /data/apps/libs
#install_from_source freetype-2.4.8.tar.gz /data/apps/libs
#install_from_source libpng-1.5.5.tar.gz /data/apps/libs
#install_from_source jpegsrc.v8c.tar.gz /data/apps/libs --enable-shared --enable-static
#install_from_source libmcrypt-2.5.8.tar.gz /data/apps/libs --enable-ltdl-install
#install_from_source mhash-0.9.9.9.tar.gz /data/apps/libs
#install_mhash
if ! grep -q /data/apps/libs /etc/ld.so.conf ;then
    echo /data/apps/libs >> /etc/ld.so.conf
    ldconfig
fi
#install_from_source mcrypt-2.6.8.tar.gz /data/apps/libs --with-libmcrypt-prefix=/data/apps/libs
ldconfig
#install_php
#install_memcache
#install_eaccelerator
install_opcache
