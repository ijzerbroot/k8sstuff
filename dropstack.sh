#!/bin/bash

sudo ls

kubectl delete -f grafana.yaml
kubectl delete -f kibana.yaml
kubectl delete -f telegraf.yaml
kubectl delete -f filebeat.yaml
kubectl delete -f fluentd-es.yaml
kubectl delete -f fluentbit.yaml
kubectl delete -f chronograf.yaml
kubectl delete -f kapacitor.yaml
kubectl delete -f influxdb.yaml
kubectl delete -f elasticsearch.yaml
kubectl delete -f traefik.yaml
kubectl delete -f kube-state-metrics.yaml
kubectl delete -f heapster.yaml
kubectl delete -f prometheus.yaml
kubectl delete -f prometheus-operator-rook.yaml
