FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

ADD media/oracle-instantclient*.x86_64.rpm /tmp/

RUN cd /tmp && \
    yum ${YUM_FLAGS_COMMON} localinstall \
            oracle-instantclient*.x86_64.rpm && \
    rm oracle-instantclient*.x86_64.rpm && \
    echo "/usr/lib/oracle/12.2/client64/lib" > /etc/ld.so.conf.d/oracle-x86_64.conf && \
    ldconfig && \
    yum ${YUM_FLAGS_COMMON} install epel-release && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            cronie \
            gcc \
            python-devel \
            python-pip \
            git 1>/dev/null && \
    pip install --no-cache-dir --upgrade pip && \
    mkdir -p /app/externalscripts && \
    cd /app && \
    git clone --depth=1 https://github.com/zyongqing/mcdb.git && \
    rm -rf .git && \
    rm -rf tests && \
    pip install --no-cache-dir --upgrade -r mcdb/requirements.txt && \
    yum ${YUM_FLAGS_COMMON} remove \
            gcc \
            python-devel \
            python-pip \
            git 1>/dev/null && \
    yum ${YUM_FLAGS_COMMON} remove epel-release && \
    yum ${YUM_FLAGS_COMMON} autoremove && \
    yum ${YUM_FLAGS_COMMON} clean all && \
    rm -rf /tmp/yum*

EXPOSE 10061/TCP

ADD run.sh /app/mcdb

ADD conf/etc/cron/baseline /app/cron/
ADD conf/etc/cron/baseline-cron /app/cron/
RUN crontab /app/cron/baseline-cron

WORKDIR /app/mcdb

ENTRYPOINT ["/bin/bash"]

CMD ["run.sh"]
