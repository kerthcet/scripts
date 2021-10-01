#!/bin/bash

set -o errexit

# set rsa
ssh-keygen -t rsa -b 4096 -C "kerthcet@gmail.com"


# set bash profile, all extra configs should be set in ~/.bash_script
rm -rf ~/.bash_script
touch ~/.bash_script

if [ -f ~/.bash_profile.bak ]
then
    cp ~/.bash_profile.bak ~/.bash_profile
else
	cp ~/.bash_profile ~/.bash_profile.bak
fi

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
alias kgno='kubectl get nodes'
alias hl='helm ls'
alias hi='helm install'
alias hui='helm uninstall'
alias kd='kubectl describe'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'
alias klft='kubectl logs -f --tail 100'
alias klfa='kubectl logs -f --all-containers --max-log-requests=10'
alias klfat='kubectl logs -f --all-containers --max-log-requests=10 --tail 100'
alias kgs='kubectl get service'
alias kgsec="kubectl get secrets"
alias kgsc="kubectl get storageclass"
alias kdel="kubectl delete"
alias kdeld="kubectl delete deployment"
alias keti="kubectl exec -it"

# docker
alias d='docker'
EOF


# yum tools
yum install -y wget
yum install -y git


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


# change repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


# dnf
yum install -y epel-release
yum install -y dnf
dnf install -y dnf-plugins-core


# kubernetes tools
# --disableexcludes 禁掉除了kubernetes之外的别的仓库
yum install -y kubeadm-1.22.1 kubectl-1.22.1 --disableexcludes=kubernetes


# install kubectx
dnf copr enable -y audron/kubectx
dnf install kubectx

# install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
