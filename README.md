# Ansible Playbook installation guide for Essential PKS (kubernetes 1.16.0+vmware.1-1)

Build a Kubernetes cluster using Ansible with kubeadm on Ubuntu 18.04 machines. The goal is to easily install a Kubernetes cluster on an air-gapped environment. In order to do that, we use aptly service to mirror the workload onto an Ubuntu 18.04 machine (called aptly server in the following description). Aptly service must be ready before applying ansible-playbook.
# Pre-requisite: 
The following installation follows this topology. 
![Setup Diagram](https://github.com/shawnho1018/kubeadm-ansible/blob/master/architecture.png)
## Prepare Aptly Service
```
apt-get install rng-tools aptly
% check for sufficient entropy
rngd -r /dev/urandom
% Import keys from heptio repo and main ubuntu repo. 
gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys 915493E7001E5CC9
gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keys.gnupg.net --recv-keys 3B4FE6ACC0B21F32

% Create Aptly Mirror
aptly mirror create essential-pks https://downloads.heptio.com/essential-pks/523a448aa3e9a0ef93ff892dceefee0a/debs stable main
DIST=$(grep CODENAME /etc/lsb-release | awk -F "=" '{ print $2 }')
aptly mirror create -architectures=amd64 -filter='socat' -filter-with-deps $DIST-main http://archive.ubuntu.com/ubuntu/ $DIST main

% Update Mirror
aptly mirror update essential-pks
aptly mirror update $DIST-main

% Create Snapshot from the mirror
aptly snapshot create essential-pks from mirror essential-pks
aptly snapshot create $DIST-main-final from mirror $DIST-main

% Publish both snapshots
aptly publish snapshot essential-pks
aptly publish snapshot $DIST-main-final

% export gpg key. This key will be used on all kubernetes nodes. We'll use ansible to apply the key to all kubernetes nodes. 
gpg --export --armor > epks_repo_key.pub
```  

## Modify Ansible-playbook files
- Since server with aptly service may have different IP address, this variable, 『essential_apt』 needs to be provided to roles/commons/pre-install/tasks/pkg.yml before running ansible-playbook.
- gpg file must be named as epks_repo_key.pub and also be stored under /root. 

# System requirements:

  - Deployment environment must have Ansible `2.4.0+`
  - Master and nodes must have passwordless SSH access

# Usage

Add the system information gathered above into a file called `hosts.ini`. For example:
```
[master]
10.66.202.112 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_user=root

[node]
10.66.202.113 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_user=root

[gpu]
192.168.0.112 ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_user=root

[kube-cluster:children]
master
node
gpu

```

Before continuing, edit `group_vars/all.yml` to your specified configuration.

For example, I choose to run `flannel` instead of calico, and thus:

```yaml
# Network implementation('flannel', 'calico')
network: flannel
```

**Note:** Depending on your setup, you may need to modify `cni_opts` to an available network interface. By default, `kubeadm-ansible` uses `eth1`. Your default interface may be `eth0`.

After going through the setup, run the `site.yaml` playbook:

```sh
$ ansible-playbook -i hosts.ini site.yaml
PLAY [master] ****************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************
Saturday 10 August 2019  11:26:37 +0800 (0:00:00.191)       0:03:05.585 *******
ok: [10.66.202.112]

TASK [Helm role] *************************************************************************************************************************************************************
Saturday 10 August 2019  11:26:38 +0800 (0:00:00.845)       0:03:06.431 *******
skipping: [10.66.202.112]

TASK [MetalLB role] **********************************************************************************************************************************************************
Saturday 10 August 2019  11:26:38 +0800 (0:00:00.046)       0:03:06.477 *******
skipping: [10.66.202.112]

TASK [Healthcheck role] ******************************************************************************************************************************************************
Saturday 10 August 2019  11:26:38 +0800 (0:00:00.045)       0:03:06.522 *******
skipping: [10.66.202.112]

PLAY RECAP *******************************************************************************************************************************************************************
10.66.202.112              : ok=39   changed=12   unreachable=0    failed=0    skipped=18   rescued=0    ignored=1
10.66.202.113              : ok=31   changed=7    unreachable=0    failed=0    skipped=15   rescued=0    ignored=0
192.168.0.112              : ok=33   changed=5    unreachable=0    failed=0    skipped=20   rescued=0    ignored=1

```

The playbook will download `/etc/kubernetes/admin.conf` file to `$HOME/admin.conf`.

If it doesn't work download the `admin.conf` from the master node:

```sh
$ scp k8s@k8s-master:/etc/kubernetes/admin.conf .
```

Verify cluster is fully running using kubectl:

```sh

$ export KUBECONFIG=~/admin.conf
$ kubectl get node
NAME    STATUS   ROLES    AGE   VERSION
linux   Ready    master   13h   v1.16.0+vmware.1


$ kubectl get po -n kube-system
NAME                                    READY     STATUS    RESTARTS   AGE
etcd-master1                            1/1       Running   0          23m
...
```

# Resetting the environment

Finally, reset all kubeadm installed state using `reset-site.yaml` playbook:

```sh
$ ansible-playbook reset-site.yaml -i hosts.ini
```

# Additional features
These are features that you could want to install to make your life easier.

Enable/disable these features in `group_vars/all.yml` (all disabled by default):
```
# Additional feature to install
additional_features:
  helm: false
  metallb: false
  healthcheck: false
```

## Helm
This will install helm in your cluster (https://helm.sh/) so you can deploy charts.

## MetalLB
This will install MetalLB (https://metallb.universe.tf/), very useful if you deploy the cluster locally and you need a load balancer to access the services.

## Healthcheck
This will install k8s-healthcheck (https://github.com/emrekenci/k8s-healthcheck), a small application to report cluster status.

# Utils
Collection of scripts/utilities

## Vagrantfile
This Vagrantfile is taken from https://github.com/ecomm-integration-ballerina/kubernetes-cluster and slightly modified to copy ssh keys inside the cluster (install https://github.com/dotless-de/vagrant-vbguest is highly recommended)

# Tips & Tricks
If you use vagrant or your remote user is root, add this to `hosts.ini`
```
[master]
192.16.35.12 ansible_user='root'

[node]
192.16.35.[10:11] ansible_user='root'
```
