FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

RUN OS_VERSION=$(sed -rn 's/.*([0-9])\.[0-9]\..*/\1/p' /etc/centos-release) && \
    yum ${YUM_FLAGS_COMMON} localinstall \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_VERSION.noarch.rpm && \
    groupadd -g 500 zabbix && \
    useradd -u 500 -g zabbix -d /var/lib/zabbix/ zabbix && \
    mkdir -p /etc/zabbix && \
    mkdir -p /etc/zabbix/zabbix_agentd.d && \
    mkdir -p /var/lib/zabbix && \
    mkdir -p /var/lib/zabbix/enc && \
    mkdir -p /var/lib/zabbix/modules && \
    chown --quiet -R zabbix:root /var/lib/zabbix && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            supervisor \
            openssl-libs 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove epel-release 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

ARG MAJOR_VERSION=3.0
ARG ZBX_VERSION=${MAJOR_VERSION}.8
ARG ZBX_SOURCES=svn://svn.zabbix.com/tags/${ZBX_VERSION}/
ENV ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES}

RUN OS_VERSION=$(sed -rn 's/.*([0-9])\.[0-9]\..*/\1/p' /etc/centos-release) && \
    yum ${YUM_FLAGS_COMMON} localinstall \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_VERSION.noarch.rpm && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            make \
            automake \
            libssh2-devel \
            subversion 1>/dev/null && \
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
            --enable-agent \
            --enable-ipv6 \
            --with-openssl && \
    make -j"$(nproc)" -s 1>/dev/null && \
    cp src/zabbix_agent/zabbix_agentd /usr/sbin/zabbix_agentd && \
    cp conf/zabbix_agentd.conf /etc/zabbix/ && \
    chown --quiet -R zabbix:root /etc/zabbix && \
    cd /tmp/ && \
    rm -rf /tmp/zabbix-${ZBX_VERSION} && \
    yum ${YUM_FLAGS_COMMON} remove \
            epel-release \
            gcc \
            make \
            automake \
            libssh2-devel \
            subversion 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

EXPOSE 10050/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/etc/zabbix/zabbix_agentd.d", "/var/lib/zabbix/enc", "/var/lib/zabbix/modules"]

ADD conf/etc/supervisor/ /etc/supervisor/
ADD run_zabbix_component.sh /

ENTRYPOINT ["/bin/bash"]

CMD ["/run_zabbix_component.sh", "agentd", "none"]
