FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ARG DB_TYPE=mysql
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

RUN OS_VERSION=$(sed -rn 's/.*([0-9])\.[0-9]\..*/\1/p' /etc/centos-release) && \
    yum ${YUM_FLAGS_COMMON} localinstall \
        https://dl.fedoraproject.org/pub/epel/epel-release-latest-$OS_VERSION.noarch.rpm \
        http://rpms.famillecollet.com/enterprise/remi-release-$OS_VERSION.rpm && \
    groupadd -g 500 zabbix && \
    useradd -u 500 -g zabbix -d /var/lib/zabbix/ zabbix && \
    mkdir -p /etc/zabbix && \
    mkdir -p /etc/zabbix/web && \
    chown --quiet -R zabbix:root /etc/zabbix && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} --enablerepo=remi-php55 install \
            supervisor \
            mysql \
            nginx \
            php \
            php-fpm \
            php-mysql \
            php-gd \
            php-json \
            php-ldap \
            php-mbstring \
            php-bcmath \
            php-xml \
            dejavu-sans-fonts 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove \
        epel-release \
        remi-release 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

ARG MAJOR_VERSION=3.0
ARG ZBX_VERSION=${MAJOR_VERSION}.8
ARG ZBX_SOURCES=https://github.com/zyongqing/aop.git
ENV ZBX_VERSION=${ZBX_VERSION} ZBX_SOURCES=${ZBX_SOURCES} DB_TYPE=${DB_TYPE}

RUN yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            git \
            gettext 1>/dev/null && \
    cd /tmp && \
    git clone ${ZBX_SOURCES} 1>/dev/null && \
    mv aop/frontends/php /usr/share/zabbix && \
    cd /usr/share/zabbix/ && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8 && \
    chmod +x ./locale/*.sh && \
    ./locale/make_mo.sh 2>/dev/null && \
    rm -rf tests && \
    yum ${YUM_FLAGS_COMMON} remove \
        git \
        gettext 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/aop && \
    rm -rf /tmp/yum*

EXPOSE 80/TCP 443/TCP

WORKDIR /usr/share/zabbix

VOLUME ["/etc/ssl/nginx"]

ADD conf/etc/supervisor/ /etc/supervisor/
ADD conf/etc/zabbix/nginx.conf /etc/zabbix/
ADD conf/etc/zabbix/nginx_ssl.conf /etc/zabbix/
ADD conf/etc/zabbix/web/zabbix.conf.php /etc/zabbix/web/
ADD conf/etc/nginx/nginx.conf /etc/nginx/
ADD conf/etc/php/fpm/conf.d/99-zabbix.ini /etc/php.d/
ADD run_zabbix_component.sh /

ENTRYPOINT ["/bin/bash"]

CMD ["/run_zabbix_component.sh", "frontend", "mysql", "nginx"]
