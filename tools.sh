#!/bin/bash

set -o errexit


# install docker
echo "install docker"
curl -v -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
systemctl start docker
echo "=========docker version========="
docker version
echo "================================"
rm -rf ./get-docker.sh


# install kind
echo "install kind"
curl -v --retry 5 -sSLo ./kind -w "%{http_code}" "https://kind.sigs.k8s.io/dl/v0.11.1/kind-${OS:-linux}-${ARCH:-amd64}" | grep '200'
chmod +x ./kind
rm -rf /usr/local/bin/kind
mv ./kind /usr/local/bin/kind
echo "=========kind version========="
kind version
echo "=============================="

# install nerdctl
VERSION=0.11.0
wget -c https://github.com/containerd/nerdctl/releases/download/v${VERSION}/nerdctl-full-${VERSION}-linux-amd64.tar.gz
tar xvf nerdctl-full-${VERSION}-linux-amd64.tar.gz -C /usr/local/

# install etcd
go get go.etcd.io/etcd/etcdctl/v3
# go get github.com/coreos/etcd/etcdctl
# cd <go-dir>/src/github.com/coreos/etcd/etcdctl
# go build .
# ls | grep etcdctl         check etcdctl is grenerated
# sudo mv etcdctl /usr/local/bin

etcdctl --help

