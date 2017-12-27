#!/bin/bash

sudo ls

kubectl delete -f es-ingress.yaml
kubectl delete -f es-service.yml
kubectl delete -f es-deployment.yml
kubectl delete -f es-serviceaccount.yml
kubectl delete -f es-clusterrolebinding.yml
kubectl delete -f es-clusterrole.yml

kubectl delete -f filebeat-ds.yaml
kubectl delete -f filebeat-config.yaml
kubectl delete -f filebeat-serviceaccount.yaml
kubectl delete -f filebeat-rolebinding.yaml
kubectl delete -f filebeat-role.yaml

kubectl delete -f influxdb-service.yaml
kubectl delete -f influxdb-deployment.yaml
kubectl delete -f influxdb-serviceaccount.yaml
kubectl delete -f influxdb-rolebinding.yaml
kubectl delete -f influxdb-role.yaml

kubectl delete -f telegraf-ds.yaml
kubectl delete -f tgconfig.yaml
kubectl delete -f telegraf-serviceaccount.yaml
kubectl delete -f telegraf-rolebinding.yaml
kubectl delete -f telegraf-role.yaml

kubectl delete -f kapacitor-service.yaml
kubectl delete -f kapacitor-deployment.yaml
kubectl delete -f kapacitor-config.yaml
kubectl delete -f kapacitor-serviceaccount.yaml
kubectl delete -f kapacitor-rolebinding.yaml
kubectl delete -f kapacitor-role.yaml

kubectl delete -f chronograf-ingress.yaml
kubectl delete -f chronograf-service.yaml
kubectl delete -f chronograf-deployment.yaml
kubectl delete -f chronograf-serviceaccount.yaml
kubectl delete -f chronograf-rolebinding.yaml
kubectl delete -f chronograf-role.yaml

kubectl delete -f kibana-ingress.yaml
kubectl delete -f kibana-service.yaml
kubectl delete -f kibana-deployment.yaml
kubectl delete -f kibana-serviceaccount.yaml
kubectl delete -f kibana-clusterrolebinding.yaml
kubectl delete -f kibana-clusterrole.yaml
