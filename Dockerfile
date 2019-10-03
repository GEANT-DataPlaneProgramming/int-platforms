FROM p4lang/p4c:latest
MAINTAINER Seth Fowler <seth@barefootnetworks.com>
MAINTAINER Robert Soule <robert.soule@barefootnetworks.com>

# Install dependencies and some useful tools.
ENV NET_TOOLS iputils-arping \
              iputils-ping \
              iputils-tracepath \
              net-tools \
              nmap \
              python-ipaddr \
              python-scapy \
              tcpdump \
              traceroute \
              tshark
ENV MININET_DEPS automake \
                 build-essential \
                 cgroup-bin \
                 ethtool \
                 gcc \
                 help2man \
                 iperf \
                 iproute \
                 libtool \
                 make \
                 pkg-config \
                 psmisc \
                 socat \
                 ssh \
                 sudo \
                 telnet \
                 pep8 \
                 pyflakes \
                 pylint \
                 python-pexpect \
                 python-setuptools
ENV DEV_TOOLS nano

# Ignore questions when installing with apt-get:
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends $NET_TOOLS $MININET_DEPS $DEV_TOOLS

# Fix to get tcpdump working
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

# Install mininet.
COPY docker/third-party/mininet /third-party/mininet
COPY bin /usr/local/bin
WORKDIR /usr/local/bin
RUN chmod u+x * 
WORKDIR /third-party/mininet
RUN cp util/m /usr/local/bin/m
RUN make install && \
    rm -rf /third-party/mininet
COPY v1model.p4 /usr/local/share/p4c/p4include 
# Install the scripts we use to run and test P4 apps.
COPY docker/scripts /scripts
WORKDIR /scripts
RUN chmod u+x send.py receive.py

ENTRYPOINT ["./p4apprunner.py"]
