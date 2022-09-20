#!/bin/bash
# set -eux;

images="
nginx:1.19-alpine
haproxy:2.3-alpine
traefik:2.4.8
openresty/openresty:1.19.3.1-alpine
envoyproxy/envoy:v1.16.2
osixia/keepalived:2.0.20
setzero/chrony:3.5
calico/typha:v3.17.1
calico/cni:v3.17.1
calico/node:v3.17.1
calico/kube-controllers:v3.17.1
calico/pod2daemon-flexvol:v3.17.1
calico/ctl:v3.17.1
jettech/kube-webhook-certgen:v1.5.0
kubernetesui/dashboard:v2.1.0
kubernetesui/metrics-scraper:v1.0.6
quay.io/coreos/flannel:v0.13.0
quay.io/jetstack/cert-manager-cainjector:v1.1.0
quay.io/jetstack/cert-manager-webhook:v1.1.0
quay.io/jetstack/cert-manager-controller:v1.1.0
k8s.gcr.io/kube-apiserver:v1.20.6
k8s.gcr.io/kube-controller-manager:v1.20.6
k8s.gcr.io/kube-scheduler:v1.20.6
k8s.gcr.io/kube-proxy:v1.20.6
k8s.gcr.io/pause:3.2
k8s.gcr.io/etcd:3.4.13-0
k8s.gcr.io/coredns:1.7.0
k8s.gcr.io/ingress-nginx/controller:v0.43.0
k8s.gcr.io/metrics-server/metrics-server:v0.4.1
"

dest_registry=${dest_registry:-'127.0.0.1:5000/kubeadm-ha'}
for image in $images ; do 
  docker pull --platform ${1:-'linux/amd64'} $image
  count=$(echo $image | grep -o '/*' | wc -l)
  if [[ $count -eq 0 ]]; then
    dest=$dest_registry/$image
  elif [[ $count -eq 1 ]]; then
    if [[ $image =~ 'k8s.gcr.io' ]]; then
      dest=$dest_registry/$(echo ${image#*/} | sed 's / _ g')
    else
      dest=$dest_registry/$(echo ${image} | sed 's / _ g')
    fi
  else
    dest=$dest_registry/$(echo ${image#*/} | sed 's / _ g')
  fi
  docker tag $image $dest
  docker push $dest
done