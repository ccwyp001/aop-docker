FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ARG DB_TYPE=mysql
ENV MIBDIRS=/usr/share/snmp/mibs:/var/lib/zabbix/mibs MIBS=+ALL
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

RUN yum ${YUM_FLAGS_COMMON} install epel-release && \
    groupadd -g 500 zabbix && \
    useradd -u 500 -g zabbix -d /var/lib/zabbix/ zabbix && \
    mkdir -p /etc/zabbix/ && \
    mkdir -p /var/lib/zabbix && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    mkdir -p /var/lib/zabbix/ssh_keys && \
    mkdir -p /var/lib/zabbix/ssl && \
    mkdir -p /var/lib/zabbix/ssl/certs && \
    mkdir -p /var/lib/zabbix/ssl/keys && \
    mkdir -p /var/lib/zabbix/ssl/ssl_ca && \
    mkdir -p /var/lib/zabbix/mibs && \
    mkdir -p /var/lib/zabbix/snmptraps && \
    mkdir -p /usr/lib/zabbix/externalscripts && \
    mkdir -p /usr/lib/zabbix/alertscripts && \
    chown --quiet -R zabbix:root /var/lib/zabbix && \
    mkdir -p /usr/share/doc/zabbix-server-${DB_TYPE} && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            supervisor \
            mysql \
            iksemel \
            net-snmp-libs \
            libcurl \
            unixODBC \
            libssh2 \
            openssl-libs \
            libxml2 \
            fping \
            OpenIPMI-libs 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove epel-release 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

ARG MAJOR_VERSION=3.0
ARG ZBX_VERSION=${MAJOR_VERSION}.8
ARG ZBX_SOURCES=https://github.com/zyongqing/aop.git
ENV ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES} DB_TYPE=${DB_TYPE}

RUN yum ${YUM_FLAGS_COMMON} install epel-release && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            make \
            automake \
            mysql-devel \
            net-snmp-devel \
            libcurl-devel \
            openldap-devel \
            iksemel-devel \
            OpenIPMI-devel \
            libssh2-devel \
            unixODBC-devel \
            libxml2-devel \
            git 1>/dev/null && \
    cd /tmp/ && \
    git clone --depth=1 ${ZBX_SOURCES} 1>/dev/null && \
    cd /tmp/aop && \
    ZABBIX_REVISION=`git rev-parse HEAD` | sed -n 's/^\(.....\).*/\1/p' && \
    sed -i "s/{ZABBIX_REVISION}/$ZABBIX_REVISION/g" include/version.h && \
    chmod +x ./bootstrap.sh && \
    chmod +x create/bin/*.pl && \
    ./bootstrap.sh 1>/dev/null && \
    ./configure \
            --prefix=/usr \
            --silent \
            --sysconfdir=/etc/zabbix \
            --libdir=/usr/lib/zabbix \
            --datadir=/usr/lib \
            --enable-server \
            --enable-ipv6 \
            --with-jabber \
            --with-ldap \
            --with-net-snmp \
            --with-openipmi \
            --with-ssh2 \
            --with-libcurl \
            --with-unixodbc \
            --with-libxml2 \
            --with-openssl \
            --with-${DB_TYPE} && \
    make -j"$(nproc)" -s dbschema 1>/dev/null && \
    make -j"$(nproc)" -s 1>/dev/null && \
    cp src/zabbix_server/zabbix_server /usr/sbin/zabbix_server && \
    cp conf/zabbix_server.conf /etc/zabbix && \
    chown --quiet -R zabbix:root /etc/zabbix && \
    cp database/${DB_TYPE}/schema.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    cp database/${DB_TYPE}/images.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    cp database/${DB_TYPE}/data.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    rm -rf /tmp/aop && \
    yum ${YUM_FLAGS_COMMON} remove \
            gcc \
            make \
            automake \
            mysql-devel \
            net-snmp-devel \
            libcurl-devel \
            iksemel-devel \
            OpenIPMI-devel \
            libssh2-devel \
            unixODBC-devel \
            libxml2-devel \
            git 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove epel-release && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

RUN yum ${YUM_FLAGS_COMMON} install epel-release && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            python-devel \
            libssh2-devel \
            net-snmp-python \
            python-pip 1>/dev/null && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --upgrade paramiko && \
    yum ${YUM_FLAGS_COMMON} remove \
            gcc \
            python-devel \
            libssh2-devel \
            python-pip 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove epel-release && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

ADD media/NaviCLI-Linux-64-x86-*.rpm /tmp
RUN cd /tmp && \
    yum ${YUM_FLAGS_COMMON} install \
            NaviCLI-Linux-64-x86-*.rpm 1>/dev/null && \
    rm -rf NaviCLI-Linux-64-x86-*.rpm && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

EXPOSE 10051/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/usr/lib/zabbix/alertscripts", \
        "/usr/lib/zabbix/externalscripts", \
        "/var/lib/zabbix/enc",\
        "/var/lib/zabbix/modules",\
        "/var/lib/zabbix/ssh_keys", \
        "/var/lib/zabbix/ssl/certs", \
        "/var/lib/zabbix/ssl/keys", \
        "/var/lib/zabbix/ssl/ssl_ca", \
        "/var/lib/zabbix/snmptraps", \
        "/var/lib/zabbix/mibs"]

ADD conf/etc/supervisor/ /etc/supervisor/
ADD run_zabbix_component.sh /

ENTRYPOINT ["/bin/bash"]

CMD ["/run_zabbix_component.sh", "server", "mysql"]
