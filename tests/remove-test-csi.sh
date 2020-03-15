#!/bin/bash
kubectl delete -f  https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl delete -f https://github.com/kubernetes/cloud-provider-vsphere/raw/master/manifests/controller-manager/vsphere-cloud-controller-manager-ds.yaml
kubectl delete secret cpi-global-secret -n kube-system 
kubectl delete cm cloud-config -n kube-system
kubectl delete secret vsphere-config-secret --namespace=kube-system
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/rbac/vsphere-csi-controller-rbac.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/deploy/vsphere-csi-controller-ss.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/master/manifests/1.14/deploy/vsphere-csi-node-ds.yaml

