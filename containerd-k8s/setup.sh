#!/bin/bash

set -o errexit

# yum install
yum install -y wget


# set hosts
cat <<EOF > /etc/hosts
10.0.0.238 master
10.0.0.237 node1
EOF


# disable firewalld
systemctl stop firewalld
systemctl disable firewalld

# disable selinux
cp ./selinux.config /etc/selinux/config
setenforce 0

# load br_netfilter
modprobe br_netfilter

touch /etc/sysctl.d/k8s.conf
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl -p /etc/sysctl.d/k8s.conf


# install ipvs
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4
yum install -y ipset
yum install -y ipvsadm


# sync machine time
yum install chrony -y
systemctl enable chronyd
systemctl start chronyd
chronyc sources


# close swap
swapoff -a
cat >>/etc/sysctl.d/k8s.conf<<EOF
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf


# install containerd
rm -rf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
# wget https://download.fastgit.org/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
wget https://github.com/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
tar -C / -xzf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
rm -rf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
source ~/.bashrc


# start containerd
mkdir -p /etc/containerd
# containerd config default > /etc/containerd/config.toml
rm -rf /etc/containerd/config.toml
cp ./containerd-config.toml /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable containerd --now
echo `crictl version`


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


# install k8s tools
yum makecache fast -y
yum install -y kubelet-1.22.1 kubeadm-1.22.1 kubectl-1.22.1 --disableexcludes=kubernetes
echo `kubeadm version`


# start kubelet
systemctl enable --now kubelet
