#!/bin/bash

set -o errexit

# set rsa
ssh-keygen -t rsa -b 4096 -C "kerthcet@gmail.com"

# update repos
# cat <<EOF > /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
# enabled=1
# gpgcheck=0
# repo_gpgcheck=0
# gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
#         http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
# EOF

# yum isntall
yum install -y git
yum install -y wget
# dnf
yum install -y epel-release
yum install -y dnf
dnf install -y dnf-plugins-core
# kubernetes tools
# --disableexcludes 禁掉除了kubernetes之外的别的仓库
yum install -y kubelet-1.22.1 kubeadm-1.22.1 kubectl-1.22.1 --disableexcludes=kubernetes

rm -rf ~/.bash_script
touch ~/.bash_script

if [ -f ~/.bash_profile.bak ]
then
    cp ~/.bash_profile.bak ~/.bash_profile
else
	cp ~/.bash_profile ~/.bash_profile.bak
fi

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
alias klf='kubectl logs -f'

# docker
alias d='docker'
EOF

# install golang
rm -rf go*.tar.gz
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
dnf copr enable -y audron/kubectx
dnf install kubectx

# install kind
echo "install kind"
curl -v --retry 5 -sSLo ./kind -w "%{http_code}" "https://kind.sigs.k8s.io/dl/v0.11.1/kind-${OS:-linux}-${ARCH:-amd64}" | grep '200'
chmod +x ./kind
rm -rf /usr/local/bin/kind
mv ./kind /usr/local/bin/kind

source ~/.bash_profile
echo ">>>>>>>>>>DONE<<<<<<<<<<<<"
