#!/bin/bash

sudo ls
kubectl apply -f traefik-rbac.yaml
kubectl apply -f traefik-daemonset.yaml
kubectl apply -f traefik-web-ui.yaml

# weave scope
kubectl apply --namespace kube-system -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl create -f weavescope-ingress.yaml

sudo docker build -t localhost/kibana-logtrail:6.1.0 kibana

kubectl delete -f es-ingress.yaml
kubectl delete -f es-service.yml
kubectl delete -f es-deployment.yml
kubectl delete -f es-serviceaccount.yml
kubectl delete -f es-clusterrolebinding.yml
kubectl delete -f es-clusterrole.yml

kubectl create -f es-clusterrole.yml
kubectl create -f es-clusterrolebinding.yml
kubectl create -f es-serviceaccount.yml
kubectl create -f es-deployment.yml
kubectl create -f es-service.yml
kubectl create -f es-ingress.yaml

kubectl create -f logstash-config.yaml
kubectl create -f logstashyaml-config.yaml
kubectl create -f logstash-deployment.yaml
kubectl create -f logstash-service.yaml

kubectl delete -f filebeat-ds.yaml
kubectl delete -f filebeat-config.yaml
kubectl delete -f filebeat-serviceaccount.yaml
kubectl delete -f filebeat-rolebinding.yaml
kubectl delete -f filebeat-role.yaml

kubectl create -f filebeat-role.yaml
kubectl create -f filebeat-rolebinding.yaml
kubectl create -f filebeat-serviceaccount.yaml
kubectl create -f filebeat-config.yaml
kubectl create -f filebeat-ds.yaml

kubectl delete -f influxdb-service.yaml
kubectl delete -f influxdb-deployment.yaml
kubectl delete -f influxdb-serviceaccount.yaml
kubectl delete -f influxdb-rolebinding.yaml
kubectl delete -f influxdb-role.yaml

kubectl create -f influxdb-role.yaml
kubectl create -f influxdb-rolebinding.yaml
kubectl create -f influxdb-serviceaccount.yaml
kubectl create -f influxdb-deployment.yaml
kubectl create -f influxdb-service.yaml

kubectl delete -f telegraf-ds.yaml
kubectl delete -f tgconfig.yaml
kubectl delete -f telegraf-serviceaccount.yaml
kubectl delete -f telegraf-rolebinding.yaml
kubectl delete -f telegraf-role.yaml

kubectl create -f telegraf-role.yaml
kubectl create -f telegraf-rolebinding.yaml
kubectl create -f telegraf-serviceaccount.yaml
kubectl create -f tgconfig.yaml
kubectl create -f telegraf-ds.yaml

kubectl delete -f kapacitor-deployment.yaml
kubectl delete -f kapacitor-config.yaml
kubectl delete -f kapacitor-serviceaccount.yaml
kubectl delete -f kapacitor-rolebinding.yaml
kubectl delete -f kapacitor-role.yaml

kubectl create -f kapacitor-role.yaml
kubectl create -f kapacitor-rolebinding.yaml
kubectl create -f kapacitor-serviceaccount.yaml
kubectl create -f kapacitor-config.yaml
kubectl create -f kapacitor-deployment.yaml

kubectl delete -f chronograf-ingress.yaml
kubectl delete -f chronograf-service.yaml
kubectl delete -f chronograf-deployment.yaml
kubectl delete -f chronograf-serviceaccount.yaml
kubectl delete -f chronograf-rolebinding.yaml
kubectl delete -f chronograf-role.yaml

kubectl create -f chronograf-role.yaml
kubectl create -f chronograf-rolebinding.yaml
kubectl create -f chronograf-serviceaccount.yaml
kubectl create -f chronograf-deployment.yaml
kubectl create -f chronograf-service.yaml
kubectl create -f chronograf-ingress.yaml

kubectl delete -f kibana-ingress.yaml
kubectl delete -f kibana-service.yaml
kubectl delete -f kibana-deployment.yaml
kubectl delete -f kibana-serviceaccount.yaml
kubectl delete -f kibana-clusterrolebinding.yaml
kubectl delete -f kibana-clusterrole.yaml

kubectl create -f kibana-clusterrole.yaml
kubectl create -f kibana-clusterrolebinding.yaml
kubectl create -f kibana-serviceaccount.yaml
kubectl create -f kibana-deployment.yaml
kubectl create -f kibana-service.yaml
kubectl create -f kibana-ingress.yaml
