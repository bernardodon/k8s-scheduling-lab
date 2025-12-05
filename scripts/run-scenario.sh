#!/bin/bash
set -e

DIR="$(dirname "$0")/.."
MODE="${1:?Uso: $0 <default|spread|binpack>}"

echo "=== $MODE ==="

"$DIR/scripts/cleanup.sh"

kubectl apply -f "$DIR/workloads/filler-$MODE.yaml"
kubectl rollout status deployment/fragment-filler --timeout=120s || true

echo "Fillers:"
kubectl get pods -l app=fragment-filler -o wide --no-headers | awk '{print "  " $7}'

kubectl apply -f "$DIR/workloads/big.yaml"
sleep 5
kubectl rollout status deployment/fragment-big --timeout=30s 2>&1 || true

STATUS=$(kubectl get pods -l app=fragment-big -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
echo "Pod grande: $STATUS"
