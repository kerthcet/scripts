#!/bin/bash

set -o errexit
set -o pipefail

touch ~/.bash_script

# Get the aliases and functions
cat >>~/.bash_profile<<EOF
#
# add bash script
if [ -f ~/.bash_script ]; then
        . ~/.bash_script
fi
EOF

# set rsa
ssh-keygen -t rsa -b 4096 -C "kerthcet@gmail.com"

# set alias
cat >>~/.bash_script<<EOF
# k8s commands alias
alias k='kubectl'
alias kg='kubectl get'
alias kgns='kubectl get ns'
alias kaf='kubectl apply -f'
alias kgp='kubectl get pods'
alias kgd='kubectl get deployments'
alias ked='kubectl edit deployments'
alias kgpgp='kubectl get propagationpolicy'
alias kepgp='kubectl edit propagationpolicy'
alias kdm='kubeadm'
alias kns='kubens'
alias ktx='kubectx'
alias kpf='kubectl port-forward'
alias kdelf='kubectl delete -f'
alias klf='kubectl logs -f'

# docker
alias d='docker'
EOF


# install git
yum install -y git

# install golang
wget https://dl.google.com/go/go1.17.1.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
cat >>~/.bash_script<<EOF
#
# add golang path
export PATH=$PATH:/usr/local/go/bin
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
EOF
source ~/.bash_profile
echo "===========go version==========="
go version
echo "================================"
rm -rf go1.17.1.linux-amd64.tar.gz

# install docker
echo "install docker"
curl -v -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
systemctl start docker
echo "=========docker version========="
docker version
echo "================================"
rm -rf ./get-docker.sh

# install kubectx
dnf copr enable audron/kubectx
dnf install kubectx

# install kubectl
echo "install kubectl"
ARCH=$(go env GOARCH)
OS=$(go env GOOS)
curl -v --retry 5 -sSLo ./kubectl -w "%{http_code}" https://dl.k8s.io/release/v1.18.0/bin/"$OS"/"$ARCH"/kubectl | grep '200'
chmod +x ./kubectl
rm -rf /usr/local/bin/kubectl
mv ./kubectl /usr/local/bin/kubectl

# install kind
echo "install kind"
curl -v --retry 5 -sSLo ./kind -w "%{http_code}" "https://kind.sigs.k8s.io/dl/v0.11.1/kind-${OS:-linux}-${ARCH:-amd64}" | grep '200'
chmod +x ./kind
rm -rf /usr/local/bin/kind
mv ./kind /usr/local/bin/kind

source ~/.bash_profile
echo ">>>>>>>>>>DONE<<<<<<<<<<<<"
