#!/bin/bash

# This procedure outlines the steps to build a Kubernetes (cluster) on CentOS 7 using Kubeadm (a certified Kubernetes bootstrapper).
# The script is expected to be executed as user "admin", who has to have sudo-privileges.
sudo yum -y update
sudo yum -y install ntp git
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service

# now disable selinux or configure it appropriately for a Kubernetes cluster

# Limits need to be increased system-wide
sudo bash -c "echo '
DefaultLimitNPROC=64000
DefaultLimitNPROCsoft=32000
DefaultLimitNOFILE=64000
DefaultLimitNOFILESoft=32000
' >> /etc/systemd/system.conf"

sudo bash -c "echo 'vm.max_map_count=262144
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward = 1
net.core.somaxconn=512
' > /etc/sysctl.d/kubernetes.conf"

# Transparent huge pages need to be disabled at host-level for applications such as Mongo and Oracle
sudo bash -c "echo '[Unit]
Description=Disable Transparent Huge Pages

[Service]
Type=oneshot
ExecStart=bash -c 'echo "never" | tee /sys/kernel/mm/transparent_hugepage/enabled'
ExecStart=bash -c 'echo "never" | tee /sys/kernel/mm/transparent_hugepage/defrag'

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/disable-thp.service"


sudo sysctl -p /etc/sysctl.d/kubernetes.conf
sudo systemctl enable disable-thp
sudo systemctl start disable-thp

# Add CNI tools to the system-wide path
sudo bash -c "echo 'PATH=/opt/bin:/opt/cni/bin:$PATH ; export PATH' > /etc/profile.d/sapienza.sh"
sudo chmod a+rx /etc/profile.d/sapienza.sh

# Remove existing Docker if installed
sudo yum -y remove docker docker-common docker-selinux docker-engine

# Install required base tools
sudo yum -y install -y yum-utils device-mapper-persistent-data lvm2

# optionally add Docker-repo. Normally we will be uploading and installing a specific version for maximum compatibility with Kubernetes
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Firewall-rules will be managed by Kubernetes SDN
sudo systemctl disable firewalld
sudo systemctl stop firewalld

# Install supplied Docker release rather than using latest
sudo yum -y install /home/admin/k8s/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm /home/admin/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
sudo systemctl enable docker
sudo systemctl start docker

# Clean restart
sudo shutdown -r now

# Normal case. Use latest stable Kubernetes release.
export RELEASE="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
sudo mkdir -p /opt/bin
cd /opt/bin
sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

# Special case. Use specified release
#export RELEASE="v1.9.1"
#sudo mkdir -p /opt/bin
#cd /opt/bin
#sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
#sudo chmod +x {kubeadm,kubelet,kubectl}

# Latest CNI version as of January 2018 is v0.6.0
export CNI_VERSION="v0.6.0"
sudo mkdir -p /opt/cni/bin
sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

# Setup Kubelet configuration files
export BRANCH="release-$(cut -f1-2 -d .<<< "${RELEASE##v}")"
cd "/etc/systemd/system/"
curl -L "https://raw.githubusercontent.com/kubernetes/kubernetes/${BRANCH}/build/debs/kubelet.service" | sudo bash -c "sed 's:/usr/bin:/opt/bin:g' > kubelet.service"
sudo mkdir -p "/etc/systemd/system/kubelet.service.d"
cd "/etc/systemd/system/kubelet.service.d"
curl -L "https://raw.githubusercontent.com/kubernetes/kubernetes/${BRANCH}/build/debs/10-kubeadm.conf" | sudo bash -c "sed 's:/usr/bin:/opt/bin:g' > 10-kubeadm.conf"
# Only needed on CoreOS because it has readonly protection on some paths
#sudo mkdir -p /var/lib/kubelet/volumeplugins
#cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | sed 's/--bootstrap-kubeconfig=/--volume-plugin-dir=\/var\/lib\/kubelet\/volumeplugins --bootstrap-kubeconfig=/' > /tmp/kubeconfig.new
#sudo cp /tmp/kubeconfig.new /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Add CNI tools to the sudo path
sudo bash -c "cat /etc/sudoers | sed 's/secure_path = /secure_path = \/opt\/bin:\/opt\/cni\/bin:/' > /tmp/sudoers.new"
sudo cp /tmp/sudoers.new /etc/sudoers


##### ONLY ON MASTER #####
# The apiserver-advertise-address is necesary on multi-homed hosts. Specify an address that is reachable from all nodes.
# The pod-network depends on the SDN-provider used. In this case it is set for Calico
# This example will install the latest stable version of Kubernetes
sudo kubeadm init --apiserver-advertise-address=10.1.1.10 --pod-network-cidr=192.168.0.0/16 | tee /home/admin/kubeadminit.log

# Special case: use specified Kubernetes version. It needs to be the same as chosen earlier in this script.
#sudo kubeadm init --kubernetes-version v1.9.1 --apiserver-advertise-address=10.1.1.10 --pod-network-cidr=192.168.0.0/16 | tee /home/admin/kubeadminit.log

# The output of kubeadm init should already have told you to do the following:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Calico networking. 1,7 is latest release as of January 2018
kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
###### END - ONLY ON MASTER #####

# The output from kubeadm should show how a node needs to join the cluster. The output can be found in /home/admin/kubeadminit.log.


sudo systemctl enable docker kubelet

####### After adding nodes ###########

###### labelling nodes in case you want to separate intended workload #####
#kubectl label nodes firstnodename role=rolename
#kubectl label nodes secondnodename role=rolename

# Check network-connectivity. This should give an unauthorized response on every node:
curl -k https://10.96.0.1

# If you want the master to also run workloads you need to untaint it:
# kubectl taint nodes --all node-role.kubernetes.io/master-

# Contour ingress controller:
kubectl apply -f contour.yaml
