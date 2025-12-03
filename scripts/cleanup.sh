#!/bin/bash

echo "🧹 Limpando todos os workloads..."
kubectl delete deployment,service,configmap -l app=nginx-test --ignore-not-found

echo "✅ Limpo!"
