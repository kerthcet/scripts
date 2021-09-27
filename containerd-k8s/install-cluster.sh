#!/bin/bash

set -o errexit

# retag image
ctr -n k8s.io i pull docker.io/coredns/coredns:1.8.4
ctr -n k8s.io i tag docker.io/coredns/coredns:1.8.4 registry.aliyuncs.com/k8sxio/coredns:v1.8.4


# load image
kubeadm config images pull --config kubeadm.yaml


# init cluster
kubeadm init --config kubeadm.yaml