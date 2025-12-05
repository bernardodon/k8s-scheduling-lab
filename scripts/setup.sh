#!/bin/bash
set -e

DIR="$(dirname "$0")/.."

kind delete cluster --name scheduling-lab 2>/dev/null || true
kind create cluster --config "$DIR/cluster.yaml"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set grafana.adminPassword=admin \
  --wait --timeout 10m

echo "Pronto. Use: make grafana"
