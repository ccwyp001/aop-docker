FROM centos:latest
MAINTAINER zyongqing

ARG YUM_FLAGS_COMMON="-q -y"
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 TERM=xterm

ADD media/oracle-instantclient*.x86_64.rpm /tmp/
ADD conf/etc/ld/oracle-x86_64.conf /etc/ld.so.conf.d

RUN cd /tmp && \
    yum ${YUM_FLAGS_COMMON} localinstall \
            oracle-instantclient*.x86_64.rpm && \
    rm oracle-instantclient*.x86_64.rpm && \
    ldconfig && \
    yum ${YUM_FLAGS_COMMON} install epel-release && \
    yum ${YUM_FLAGS_COMMON} update && \
    yum ${YUM_FLAGS_COMMON} install \
            gcc \
            python-devel \
            python-pip \
            git 1>/dev/null && \
    pip install --no-cache-dir --upgrade pip && \
    mkdir /app && \
    cd /app && \
    git clone https://github.com/zyongqing/mcdb.git && \
    rm -rf .git && \
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

WORKDIR /app/mcdb

ENTRYPOINT ["/bin/bash"]

CMD ["run.sh"]
