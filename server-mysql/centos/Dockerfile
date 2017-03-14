FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ARG DB_TYPE=mysql
ENV MIBDIRS=/usr/share/snmp/mibs:/var/lib/zabbix/mibs MIBS=+ALL
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

RUN OS_VERSION=$(sed -rn 's/.*([0-9])\.[0-9]\..*/\1/p' /etc/centos-release) && \
    yum ${YUM_FLAGS_COMMON} install wget 1>/dev/null && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    cd /tmp/ && \
    wget http://mirrors.163.com/.help/CentOS$OS_VERSION-Base-163.repo && \
    mv /tmp/CentOS$OS_VERSION-Base-163.repo /etc/yum.repos.d/ && \
    yum ${YUM_FLAGS_COMMON} localinstall \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_VERSION.noarch.rpm && \
    yum clean all && \
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
    yum ${YUM_FLAGS_COMMON} remove \
            wget \
            epel-release.noarch 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /etc/yum.repos.d/CentOS$OS_VERSION-Base-163.repo && \
    mv /etc/yum.repos.d/CentOS-Base.repo.backup /etc/yum.repos.d/CentOS-Base.repo && \
    rm -rf /tmp/*.repo && \
    rm -rf /tmp/yum*

ARG MAJOR_VERSION=3.0
ARG ZBX_VERSION=${MAJOR_VERSION}.8
ARG ZBX_SOURCES=svn://svn.zabbix.com/tags/${ZBX_VERSION}/
ENV ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES} DB_TYPE=${DB_TYPE}

RUN OS_VERSION=$(sed -rn 's/.*([0-9])\.[0-9]\..*/\1/p' /etc/centos-release) && \
    yum ${YUM_FLAGS_COMMON} install wget 1>/dev/null && \
    mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
    cd /tmp/ && \
    wget http://mirrors.163.com/.help/CentOS$OS_VERSION-Base-163.repo && \
    mv /tmp/CentOS$OS_VERSION-Base-163.repo /etc/yum.repos.d/ && \
    yum ${YUM_FLAGS_COMMON} localinstall \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_VERSION.noarch.rpm && \
    yum clean all && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            make \
            automake \
            pkgconfig \
            mysql-devel \
            net-snmp-devel \
            libcurl-devel \
            openldap-devel \
            iksemel-devel \
            OpenIPMI-devel \
            libssh2-devel \
            unixODBC-devel \
            libxml2-devel \
            subversion && \
    cd /tmp/ && \
    svn --quiet export ${ZBX_SOURCES} zabbix-${ZBX_VERSION} && \
    cd /tmp/zabbix-${ZBX_VERSION} && \
    ZABBIX_REVISION=`svn info ${ZBX_SOURCES} |grep "Last Changed Rev"|awk '{print $4;}'` && \
    sed -i "s/{ZABBIX_REVISION}/$ZABBIX_REVISION/g" include/version.h && \
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
            --with-${DB_TYPE} 1>/dev/null && \
    make -j"$(nproc)" -s dbschema 1>/dev/null && \
    make -j"$(nproc)" -s 1>/dev/null && \
    cp src/zabbix_server/zabbix_server /usr/sbin/zabbix_server && \
    cp conf/zabbix_server.conf /etc/zabbix && \
    chown --quiet -R zabbix:root /etc/zabbix && \
    cp database/${DB_TYPE}/schema.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    cp database/${DB_TYPE}/images.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    cp database/${DB_TYPE}/data.sql /usr/share/doc/zabbix-server-${DB_TYPE}/ && \
    cd /tmp/ && \
    rm -rf /tmp/zabbix-${ZBX_VERSION}/ && \
    yum ${YUM_FLAGS_COMMON} remove \
            wget \
            epel-release.noarch \
            gcc \
            make \
            automake \
            pkgconfig \
            mysql-devel \
            net-snmp-devel \
            libcurl-devel \
            openldap-devel \
            iksemel-devel \
            OpenIPMI-devel \
            libssh2-devel \
            unixODBC-devel \
            libxml2-devel \
            subversion 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /etc/yum.repos.d/CentOS$OS_VERSION-Base-163.repo && \
    mv /etc/yum.repos.d/CentOS-Base.repo.backup /etc/yum.repos.d/CentOS-Base.repo && \
    rm -rf /tmp/*.repo && \
    rm -rf /tmp/yum*

EXPOSE 10051/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/usr/lib/zabbix/alertscripts", \
        "/usr/lib/zabbix/externalscripts", \
        "/var/lib/zabbix/enc",\
        "/var/lib/zabbix/modules",\
        "/var/lib/zabbix/ssh_keys"]
VOLUME ["/var/lib/zabbix/ssl/certs",\
        "/var/lib/zabbix/ssl/keys",\
        "/var/lib/zabbix/ssl/ssl_ca",\
        "/var/lib/zabbix/snmptraps",\
        "/var/lib/zabbix/mibs"]

ADD conf/etc/supervisor/ /etc/supervisor/
ADD run_zabbix_component.sh /

ENTRYPOINT ["/bin/bash"]

CMD ["/run_zabbix_component.sh", "server", "mysql"]
