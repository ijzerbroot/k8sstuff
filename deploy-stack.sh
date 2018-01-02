#!/bin/bash

sudo ls
kubectl apply -f traefik-rbac.yaml
kubectl apply -f traefik-daemonset.yaml
kubectl apply -f traefik-web-ui.yaml

# weave scope
kubectl apply --namespace kube-system -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl create -f weavescope-ingress.yaml

#sudo docker build -t localhost/kibana-logtrail:6.1.0 kibana
sudo ls

kubectl delete -f grafana.yaml
kubectl delete -f kibana.yaml
kubectl delete -f telegraf.yaml
kubectl delete -f filebeat.yaml
kubectl delete -f fluentd.yaml
kubectl delete -f chronograf.yaml
kubectl delete -f kapacitor.yaml
kubectl delete -f influxdb.yaml
kubectl delete -f elasticsearch.yaml
kubectl delete -f traefik.yaml
kubectl delete -f kube-state-metrics.yaml
kubectl delete -f heapster.yaml
kubectl delete -f prometheus.yaml
kubectl delete -f prometheus-operator-rook.yaml

kubectl create -f heapster.yaml
kubectl create -f kube-state-metrics.yaml
kubectl create -f elasticsearch.yaml
kubectl create -f influxdb.yaml
kubectl create -f kapacitor.yaml
kubectl create -f grafana.yaml
kubectl create -f kibana.yaml
kubectl create -f telegraf.yaml
#kubectl create -f filebeat.yaml
kubectl create -f fluentd.yaml
kubectl create -f chronograf.yaml
kubectl create -f traefik.yaml
kubectl create -f prometheus.yaml
kubectl create -f prometheus-operator-rook.yaml

#kubectl create -f https://github.com/kubernetes/kubernetes/blob/master/cluster/addons/cluster-monitoring/heapster-rbac.yaml
#kubectl create -f https://github.com/kubernetes/heapster/blob/master/deploy/kube-config/influxdb/heapster.yaml
