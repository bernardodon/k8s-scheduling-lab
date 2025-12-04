#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🧹 Limpando workloads..."
make -C "$ROOT_DIR" clean

echo "📝 Aplicando ConfigMap..."
kubectl apply -f "$ROOT_DIR/workloads/nginx-test/configmap.yaml"

echo "🚀 Aplicando deployment heavy..."
kubectl apply -f "$ROOT_DIR/workloads/nginx-test/deployment-heavy.yaml"

echo "⏳ Aguardando 30s..."
sleep 30

echo "📊 Status:"
make -C "$ROOT_DIR" status
