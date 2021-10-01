nerdctl -n k8s.io pull registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-node-driver-registrar:v2.2.0
nerdctl -n k8s.io tag registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-node-driver-registrar:v2.2.0 k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0

nerdctl -n k8s.io pull registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-attacher:v3.2.1
nerdctl -n k8s.io tag registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-attacher:v3.2.1 k8s.gcr.io/sig-storage/csi-attacher:v3.2.1

nerdctl -n k8s.io pull registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-resizer:v1.2.0
nerdctl -n k8s.io tag registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-resizer:v1.2.0 k8s.gcr.io/sig-storage/csi-resizer:v1.2.0

nerdctl -n k8s.io pull registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-snapshotter:v4.1.1
nerdctl -n k8s.io tag registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-snapshotter:v4.1.1 k8s.gcr.io/sig-storage/csi-snapshotter:v4.1.1

nerdctl -n k8s.io pull registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-provisioner:v2.2.2
nerdctl -n k8s.io tag registry.cn-shanghai.aliyuncs.com/kerthcet-public/csi-provisioner:v2.2.2 k8s.gcr.io/sig-storage/csi-provisioner:v2.2.2

