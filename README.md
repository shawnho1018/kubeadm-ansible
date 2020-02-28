# Ansible Playbook installation guide for TKG (Tanzu Kubernetes Grid) on CentOS 7. 
This version has been tested for both Ubuntu 18.04 and CentOS7. However, they are testing at different time. Ubuntu 18.04 has been tested for K8S 16.2; while CentOS7 has been tested against K8S 17.3, 16.6 and 16.2. 

This version requires internet-friendly environment. Below, I'll use CentOS 7 as example to explain the usage. 
## Pre-Requirement
* Prepare at least 2 CentOS 7 machines. For CentOS7 ISO, please check from [this link](http://isoredirect.centos.org/centos/7/isos/x86_64/)
* Add User account with sudoer privilege into each CentOS. This script supports both password aor CA login. 
* Remove Sudo password prompt. If you don't know how, please use [this link](http://jonmoore.duckdns.org/index.php/linux-articles/58-remove-sudo-password-prompt) 

## How to use this script
* Edit version information in group_vars/all.yml. You can put either 1.16.2, 1.16.6 or 1.17.3. To the date, 1.17.3 is the latest version. 
* Please modify host.ini to put your CentOS's IP address and credentials. The default host.ini use ssh private key to login.
* Check site.yaml. If everything is ok, 『ansible-playbook -i hosts.ini site.yaml 』
* For any issue, you can use ansible-playbook -i hosts.ini reset-site.yaml to remove all installed items. 
