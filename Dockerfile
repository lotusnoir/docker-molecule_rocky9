FROM rockylinux/rockylinux:9
LABEL maintainer="lotusnoir"

ENV container docker
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /lib/systemd/system/sysinit.target.wants/
RUN (for i in *; do [ "${i}" = "systemd-tmpfiles-setup.service" ] || rm -f "${i}"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*; \
    yum -y install rpm dnf-plugins-core \
    && yum -y update \
    && yum -y install epel-release initscripts sudo which hostname libyaml python3 python3-pip python3-pyyaml wget iproute \
    && python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir ansible cryptography jmespath \
    && yum clean all && rm -rf /tmp/* /var/tmp/* /usr/share/doc /usr/share/man \
    && wget -q -O /usr/local/bin/goss https://github.com/aelsabbahy/goss/releases/download/v0.3.21/goss-linux-amd64 && chmod +x /usr/local/bin/goss

VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/lib/systemd/systemd"]
