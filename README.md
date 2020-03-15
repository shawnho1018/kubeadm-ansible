# Ansible Playbook installation guide for TKG (Tanzu Kubernetes Grid) on CentOS 7. 
This version has been tested for both Ubuntu 18.04 and CentOS7. However, they are testing at different time. Ubuntu 18.04 has been tested for K8S 16.2; while CentOS7 has been tested against K8S 17.3, 16.6 and 16.2. 

This version requires internet-friendly environment and vSphere 6.7U3 (or After) version. Below, I'll use CentOS 7 as example to explain the usage. 

[New Function] Add CPI/CSI support. Since CSI support is only available after vSphere 6.7U3, please use this version afterwards to gain such a support. 

## Pre-Requirement
* Prepare at least 2 CentOS 7 machines. For CentOS7 ISO, please check from [this link](http://isoredirect.centos.org/centos/7/isos/x86_64/)
* Add User account with sudoer privilege into each CentOS. This script supports both password aor CA login. 
* Remove Sudo password prompt. If you don't know how, please use [this link](http://jonmoore.duckdns.org/index.php/linux-articles/58-remove-sudo-password-prompt) 

## How to use this script
* Edit version information in group_vars/all.yml. You can put either 1.16.2, 1.16.6 or 1.17.3. To the date, 1.17.3 is the latest version. 
* Please modify host.ini to put your CentOS's IP address and credentials. The default host.ini use ssh private key to login.
* Check site.yaml. If everything is ok, 『ansible-playbook -i hosts.ini site.yaml 』
* CPI/CSI plugin requires the following information of your vcenter. This settings can be modified from group_vars/all.yml.

```yaml
# CPI/CSI Installation
# CPI config
# no "" sign for vsphere_ip

vsphere_ip: vc.syspks.com
datacenter_name: "DC25"
vcenter_user: "shawn@syspks.sso"
vcenter_pass: "password"
cluster_id: "syspks"
```

* For those who hopes to drop CPI/CSI support, please comment CSI role in site.yaml
```yaml
- hosts: master
  gather_facts: yes
  become: yes
  roles:
    - {role: csi, tags: csi}
```
* After kubernetes cluster with CPI/CSI is created, we need to configure a storage policy in vCenter and then run the following yaml file to configure the StorageClass. 
```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: standard
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: csi.vsphere.vmware.com
parameters:
  storagepolicyname: "YOUR-STORAGE-POLICY-NAME"
  fstype: ext4
```

## If problems occurs...
* For any issue, you can use ansible-playbook -i hosts.ini reset-site.yaml to remove all installed items. 

