
git clone https://github.com/komljen/kube-elk-filebeat
cd kube-elk-filebeat
kubectl create -f kubefiles/ -R --namespace=default
