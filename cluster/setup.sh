#!/bin/bash
set -e

CLUSTER_NAME="scheduling-lab"

echo "🚀 Criando cluster Kind..."

# Deletar cluster existente se houver
kind delete cluster --name $CLUSTER_NAME 2>/dev/null || true

# Criar cluster
kind create cluster --config kind-config.yaml

# Verificar nodes
echo ""
echo "📋 Nodes criados:"
kubectl get nodes

echo ""
echo "✅ Cluster pronto!"
