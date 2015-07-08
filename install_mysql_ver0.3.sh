#!/bin/bash

[ -e '/usr/local/mysql/bin/mysql' ] &&  echo "mysql-5.6.24 has been installed" && exit 1

rpm -q make || yum install -y make || exit 1 
rpm -q cmake ||  yum install -y cmake || exit 1 
rpm -q gcc-c++ ||  yum install -y gcc-c++ || exit 1 
rpm -q bison-devel ||  yum install -y bison-devel || exit 1 
rpm -q ncurses-devel ||  yum install -y ncurses-devel || exit 1 

if [ -d '/usr/local/mysql' ];then
    rm -rfv /usr/local/mysql
    [ $? != 0 ] && echo "Failed to remove directory /usr/local/mysql" && exit 1 
fi

if [ ! -d /data/mysql/log-bin ];then
    mkdir -pv /data/mysql/log-bin
else
    /bin/rm -rfv /data/mysql/log-bin/*
fi

if [ ! -d '/data/mysql/mysql_log' ];then
    mkdir -pv /data/mysql/mysql_log
else
    /bin/rm -rf /data/mysql/mysql_log
fi

if [ ! -d '/data/mysql/data' ];then
    mkdir -pv /data/mysql/data
else
    /bin/rm -rf /data/mysql/data
fi

if [ -n "$1" ];then
    SOURCETAR=$1
else
    SOURCETAR='/data/src/mysql-5.6.24.tar.gz'
fi

if [ ! -e "$SOURCETAR" ];then
    echo "$SOURCETAR does not exist" && exit 1
fi
test -d /data/src/mysql-5.6.24 && /bin/rm -rfv /data/src/mysql-5.6.24
tar xvf $SOURCETAR -C /data/src/
[ $? !=0 ] && echo "Error occured when untar $SOURCETAR" && exit 1

cd /data/src/mysql-5.6.24 || exit 1

#cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DWITH_SSL=yes -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_COMMENT=tianhuo_game_db -DWITH_DEBUG=0 -DMYSQL_DATADIR=/usr/local/mysql/data/

cmake \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DSYSCONFDIR=/etc \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_SSL=yes\
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci || exit 1
make || exit 1
make install || exit 1

grep -q mysql /etc/group || groupadd mysql || exit 1
if grep -q mysql /etc/passwd ;then
    usermod -g mysql mysql || exit 1
else
    useradd mysql -g mysql -M -s /sbin/nologin || exit 1
fi

chown -R mysql.mysql /usr/local/mysql/ || exit 1
chown -R mysql.mysql /data/mysql/log-bin/ || exit 1
chown -R mysql.mysql /data/mysql/mysql_log/ || exit 1
chown -R mysql.mysql /data/mysql/data
#cd /usr/local/mysql
#scripts/mysql_install_db --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql || exit 1

if [ ! -e '/data/src/my.cnf' ];then
    echo "/data/src/my.cnf does not exist,so use /usr/local/mysql/my.cnf as default,if not,you can put your my.cnf to /etc/"
else
    cp -v /data/src/my.cnf.erb /etc/my.cnf
fi

#cp -v support-files/mysql.server /etc/init.d/mysqld
cp -afv /data/src/mysqld.erb /etc/init.d/mysqld
chmod a+x /etc/init.d/mysqld
chkconfig --add mysqld || exit 1
chkconfig mysqld on || exit 1
service mysqld start
if ! echo $PATH | grep -q '/usr/local/mysql/bin' ;then
    echo -en "PATH=/usr/local/mysql/bin:$PATH\nexport PATH\n" >> /etc/profile
    source /etc/profile
fi
#awk 'BEGIN{add=1} $0 ~ "^/usr/local/mysql/lib$"{add=0}END{if(add==1)print "include /usr/local/mysql/lib" >> "/etc/ld.so.conf"}' /etc/ld.so.conf
echo '/usr/local/mysql/lib/' > /etc/ld.so.conf.d/mysql_lib.conf
ldconfig
cd -
