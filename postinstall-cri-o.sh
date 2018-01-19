
# For now needs Fedora

sudo ls
sudo systemctl enable sshd
sudo systemctl start sshd
# visudo and make wheel users sudo without password
sudo dnf -y update
sudo dnf install -y \
  btrfs-progs-devel \
  device-mapper-devel \
  git \
  glib2-devel \
  glibc-devel \
  glibc-static \
  go \
  golang-github-cpuguy83-go-md2man \
  gpgme-devel \
  libassuan-devel \
  libgpg-error-devel \
  libseccomp-devel \
  libselinux-devel \
  ostree-devel \
  pkgconfig \
  runc \
  skopeo-containers

sudo dnf -y install ntp git
sudo systemctl enable ntpd.service
sudo systemctl start ntpd.service

sudo dnf -y install cri-o
sudo systemctl enable crio
sudo systemctl start crio
# now disable selinux

sudo bash -c "echo '
DefaultLimitNPROC=64000
DefaultLimitNPROCsoft=32000
DefaultLimitNOFILE=64000
DefaultLimitNOFILESoft=32000
' >> /etc/systemd/system.conf"


sudo cp daemons.conf /etc/sysctl.d
sudo cp disable-thp.service /etc/systemd/system/disable-thp.service

sudo sysctl -p /etc/sysctl.d/daemons.conf
sudo systemctl enable disable-thp
sudo systemctl start disable-thp

sudo bash -c "echo 'PATH=/opt/bin:/opt/cni/bin:$PATH ; export PATH' > /etc/profile.d/sapienza.sh"
sudo chmod a+rx /etc/profile.d/sapienza.sh

sudo dnf -y remove docker docker-common docker-selinux docker-engine
sudo dnf -y install -y yum-utils device-mapper-persistent-data lvm2
#sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo systemctl disable firewalld
sudo systemctl stop firewalld

sudo shutdown -r now

#sudo bash -c 'echo "export KUBE_FEATURE_GATES=\"PersistentLocalVolumes=true,VolumeScheduling=true,MountPropagation=true\"" >> /etc/environment'
export RELEASE="$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"
export CNI_VERSION="v0.6.0"

sudo mkdir -p /opt/bin
cd /opt/bin
sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

sudo mkdir -p /opt/cni/bin
sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

export BRANCH="release-$(cut -f1-2 -d .<<< "${RELEASE##v}")"
cd "/etc/systemd/system/"
curl -L "https://raw.githubusercontent.com/kubernetes/kubernetes/${BRANCH}/build/debs/kubelet.service" | sudo bash -c "sed 's:/usr/bin:/opt/bin:g' > kubelet.service"
sudo mkdir -p "/etc/systemd/system/kubelet.service.d"
cd "/etc/systemd/system/kubelet.service.d"
curl -L "https://raw.githubusercontent.com/kubernetes/kubernetes/${BRANCH}/build/debs/10-kubeadm.conf" | sudo bash -c "sed 's:/usr/bin:/opt/bin:g' > 10-kubeadm.conf"
sudo mkdir -p /var/lib/kubelet/volumeplugins
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | sed 's/--bootstrap-kubeconfig=/--volume-plugin-dir=\/var\/lib\/kubelet\/volumeplugins --bootstrap-kubeconfig=/' > /tmp/kubeconfig.new
echo 'Wants=crio.service' >> /tmp/kubeconfig.new
sudo cp /tmp/kubeconfig.new /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
echo "[Service]
Environment=\"KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --image-service-endpoint /var/run/crio.sock --container-runtime-endpoint unix:///var/run/crio/crio.sock --cgroup-driver=systemd\"" > /tmp/cio.conf

sudo cp /tmp/cio.conf /etc/systemd/system/kubelet.service.d/0-crio.conf
echo '
{
    "name": "mynet",
    "type": "flannel"
}' > /tmp/flannet.conf
sudo cp /tmp/flannet.conf /etc/cni/net.d/10-flannet.conf
sudo bash -c "cat /etc/sudoers | sed 's/secure_path = /secure_path = \/opt\/bin:\/opt\/cni\/bin:/' > /tmp/sudoers.new"
sudo cp /tmp/sudoers.new /etc/sudoers

##### ONLY ON MASTER #####
sudo kubeadm init --apiserver-advertise-address=192.168.1.10 --pod-network-cidr=10.244.0.0/16 --cri-socket=/var/run/crio/crio.sock --ignore-preflight-errors=Service-Docker --ignore-preflight-errors=FileContent--proc-sys-net-bridge-bridge-nf-call-iptables | tee /home/admin/kubeadminit.log

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


#export kubever=$(kubectl version | base64 | tr -d '\n')
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
#sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml

#OF kube-router:
#KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml


# OF kube-router met alle features:
#KUBECONFIG=/etc/kubernetes/admin.conf kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter-all-features.yaml
#KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n kube-system delete ds kube-proxy
#docker run --privileged --net=host gcr.io/google_containers/kube-proxy-amd64:v1.7.3 kube-proxy --cleanup-iptables
###### END - ONLY ON MASTER #####

sudo systemctl enable crio kubelet

sudo systemctl daemon-reload
sudo systemctl stop kubelet
sudo systemctl start kubelet

# NASTY WORKAROUND for kubelet looking in wrong path:
sudo ln -s /opt/cni/bin /usr/libexec/cni
# ONLY on master
export HELM_URL=http://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz
curl "$HELM_URL" | sudo tar --strip-components 1 -C /opt/bin linux-amd64/helm -zxf -

sudo mkdir -p /kubedata/vol1

###### ONLY on MASTER  #####
kubectl label nodes threekube-node1.localdomain role=prod
kubectl label nodes threekube-node2 role=staging

# This should work from any node:
curl -k https://10.96.0.1
#sudo iptables -t nat -I POSTROUTING -s 10.244.0.7 -p udp --dport 53 -j MASQUERADE

kubectl apply -f dashboard-rbac.yaml
kubectl apply -f kubernetes-dashboard.yaml
kubectl apply -f traefik.yaml
kubectl apply -f influxdb.yaml
kubectl apply -f heapster.yaml

#kubectl apply -f lv-provisioner-config.yaml
#kubectl apply -f lv_storageclass.yaml
#kubectl apply -f local-storage-admin.yaml
