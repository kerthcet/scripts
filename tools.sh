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

