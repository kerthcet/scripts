#!/bin/bash

set -o errexit

# set hosts
if [ -f /etc/hosts.bak ]
then
    cp /etc/hosts.bak /etc/hosts
else
	cp /etc/hosts /etc/hosts.bak
fi

cat <<EOF >> /etc/hosts
10.6.24.10 master
10.6.24.11 node1
10.6.24.12 node2
EOF


# disable firewalld
systemctl stop firewalld
systemctl disable firewalld
echo `firewall-cmd --state`

# disable selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
echo `getenforce`

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
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
echo `free -m`
cat >>/etc/sysctl.d/k8s.conf<<EOF
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf


# install containerd
if [ -f cri-containerd-cni-1.5.5-linux-amd64.tar.gz ]
then
    echo "containerd already exists"
else
	echo "downloading containerd..."
	wget https://github.com/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
fi
# rm -rf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
# wget https://download.fastgit.org/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
# wget https://github.com/containerd/containerd/releases/download/v1.5.5/cri-containerd-cni-1.5.5-linux-amd64.tar.gz
tar -C / -xzf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
# rm -rf cri-containerd-cni-1.5.5-linux-amd64.tar.gz
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
source ~/.bashrc


# # install nerdctl
VERSION=0.11.0
if [ -f nerdctl-full-${VERSION}-linux-amd64.tar.gz ]
then
    echo "nerdctl already exists"
else
	echo "downloading nerdctl..."
	wget -c https://github.com/containerd/nerdctl/releases/download/v${VERSION}/nerdctl-full-${VERSION}-linux-amd64.tar.gz
fi
tar xvf nerdctl-full-${VERSION}-linux-amd64.tar.gz -C /usr/local/


# start containerd
mkdir -p /etc/containerd
# containerd config default > /etc/containerd/config.toml
rm -rf /etc/containerd/config.toml
cp ./containerd-config.toml /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable containerd --now
echo `crictl version`


# install k8s tools
yum makecache fast -y
yum install -y kubelet-1.22.1 --disableexcludes=kubernetes


# start kubelet
systemctl enable --now kubelet


# retag image
ctr -n k8s.io i pull docker.io/coredns/coredns:1.8.4
ctr -n k8s.io i tag docker.io/coredns/coredns:1.8.4 registry.aliyuncs.com/k8sxio/coredns:v1.8.4
ctr -n k8s.io i pull registry.aliyuncs.com/k8sxio/pause:3.5
ctr -n k8s.io i tag registry.aliyuncs.com/k8sxio/pause:3.5 k8s.gcr.io/pause:3.5


# load image
kubeadm config images pull --config kubeadm.yaml || true
