#!/bin/bash
zbx_server=$1
install_zabbix(){
    test -x /usr/local/zabbix/sbin/zabbix_agentd && echo "zabbix-2.2.6 has been installed on this machine" && exit 1
    cd /data/src
    [ -d zabbix-2.2.6 ] && rm -rf zabbix-2.2.6
    id zabbix || useradd zabbix
    tar xvf zabbix-2.2.6.tar.gz || { echo "failed to untar zabbix-2.2.6.tar.gz";exit 1; }
    cd zabbix-2.2.6
    ./configure --prefix=/usr/local/zabbix --enable-agent || exit 1
    make || exit 1
    make install || exit 1
    cd ..
    mkdir -p /var/run/zabbix
    chown -R zabbix.zabbix /var/run/zabbix
    sed -r -i -e "/^# PidFile=/a PidFile=\/var\/run\/zabbix\/zabbix_agentd.pid" -e "/^# EnableRemoteCommands=0/a EnableRemoteCommands=1" \
    -e "s/(Server=)127.0.0.1/\1$zbx_server/" -e "/ServerActive=127.0.0.1/ s/^/#/" -e "s/(Hostname=)Zabbix server/\1`hostname -I`/" \
    -e "/^# Timeout=3/a Timeout=30" -e "s/# (Include=\/usr\/local\/)(etc\/zabbix_agentd.conf.d\/)/\1zabbix\/\2/" \
    -e  "s/# (UnsafeUserParameters)=0/\1=1/" /usr/local/zabbix/etc/zabbix_agentd.conf
    cp -af zabbix_agentd /etc/init.d/ || { echo "zabbix_agentd does not exist in /data/src";exit 1; }
    chmod a+x /etc/init.d/zabbix_agentd
}
install_zabbix
 
