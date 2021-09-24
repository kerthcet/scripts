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
# docker
alias d='docker'
EOF

# set rsa
ssh-keygen -t rsa -b 4096 -C "kerthcet@gmail.com"

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
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
systemctl start docker
echo "=========docker version========="
docker version
echo "================================"
rm -rf ./get-docker.sh

# # install kubectl
# curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install kubectx
dnf copr enable audron/kubectx
dnf install kubectx

echo ">>>>>>>>>>DONE<<<<<<<<<<<<"
