FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

RUN yum ${YUM_FLAGS_COMMON} install epel-release && \
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
ARG ZBX_SOURCES=https://github.com/zyongqing/aop.git
ENV ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES}

RUN yum ${YUM_FLAGS_COMMON} install epel-release && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            make \
            automake \
            libssh2-devel \
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
            --enable-agent \
            --enable-ipv6 \
            --with-openssl && \
    make -j"$(nproc)" -s 1>/dev/null && \
    cp src/zabbix_agent/zabbix_agentd /usr/sbin/zabbix_agentd && \
    cp conf/zabbix_agentd.conf /etc/zabbix/ && \
    chown --quiet -R zabbix:root /etc/zabbix && \
    rm -rf /tmp/aop && \
    yum ${YUM_FLAGS_COMMON} remove \
            epel-release \
            gcc \
            make \
            automake \
            libssh2-devel \
            git 1>/dev/null && \
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
