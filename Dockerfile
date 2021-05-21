FROM ubuntu:20.04

EXPOSE 8555
EXPOSE 8444

ARG BRANCH=latest
ARG GIT_MIRROR=https://github.com/Chia-Network

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y curl jq python3 ansible tar bash ca-certificates git openssl unzip wget python3-pip sudo acl build-essential python3-dev python3.8-venv python3.8-distutils apt nfs-common vim && \
    curl -L http://gosspublic.alicdn.com/ossutil/1.7.3/ossutil64 -o /usr/bin/ossutil64 && \
    chmod 755 /usr/bin/ossutil64


ADD ./pip.conf /root/.pip/pip.conf
RUN echo "Cloning ${BRANCH} ${GIT_MIRROR}"
RUN git clone --branch ${BRANCH} ${GIT_MIRROR}/chia-blockchain.git && \
    cd chia-blockchain && \
    git config -f .gitmodules submodule.mozilla-ca.url ${GIT_MIRROR}/mozilla-ca.git && \
    git config -f .gitmodules submodule.chia-blockchain-gui.url ${GIT_MIRROR}/chia-blockchain-gui.git && \
    git submodule update --init mozilla-ca && \
    git submodule update --init chia-blockchain-gui && \
    chmod +x install.sh && \
    /bin/sh ./install.sh && \
    ln -s /chia-blockchain/venv/bin/chia /usr/local/bin/chia

WORKDIR /chia-blockchain

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
