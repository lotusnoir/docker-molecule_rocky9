FROM rockylinux/rockylinux:9.8
LABEL maintainer="lotusnoir"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV container=docker
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
STOPSIGNAL SIGRTMIN+3

WORKDIR /lib/systemd/system/sysinit.target.wants/
RUN (for i in *; do [ "${i}" = "systemd-tmpfiles-setup.service" ] || rm -f "${i}"; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*; \
    rm -f /etc/systemd/system/*.wants/*; \
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*; \
    rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum -y install dnf-plugins-core && yum -y update \
    && yum -y install epel-release initscripts sudo which hostname libyaml python3 python3-pip python3-pyyaml wget iproute vim gnupg2 \
    && yum clean all && rm -rf /tmp/* /var/tmp/* /usr/share/doc /usr/share/man

RUN python3 -m pip install --no-cache-dir --ignore-installed --upgrade pip \
    && python3 -m pip install --no-cache-dir ansible cryptography jmespath

# Pin goss version + verify checksum (update both when bumping version)
ENV GOSS_VERSION=0.4.9
ENV GOSS_SHA256="87dd36cfa1b8b50554e6e2ca29168272e26755b19ba5438341f7c66b36decc19"
RUN wget -q -O /usr/local/bin/goss \
        https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64 \
    && echo "${GOSS_SHA256}  /usr/local/bin/goss" | sha256sum -c - \
    && chmod +x /usr/local/bin/goss

# Test-only: allow passwordless/unauthenticated sudo for Ansible `become`,
# if this image needs it like the Rocky 10 variant — confirm intent first
RUN sed -i 's/PrivateNetwork=yes/PrivateNetwork=no/; s/PrivateDevices=yes/PrivateDevices=no/' \
        /lib/systemd/system/systemd-localed.service \
        /lib/systemd/system/systemd-hostnamed.service \
        /lib/systemd/system/systemd-timedated.service

VOLUME [ "/tmp", "/run", "/run/lock" ]
ENTRYPOINT ["/lib/systemd/systemd"]
