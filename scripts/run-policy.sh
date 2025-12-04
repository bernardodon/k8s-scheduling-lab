#!/bin/bash
set -e

# Simple runner to clean, deploy a policy, and capture outputs in results/.
# Usage: ./scripts/run-policy.sh <policy>

POLICY="$1"
if [ -z "$POLICY" ]; then
  echo "Uso: $0 <policy>"
  echo "Políticas: default | spreading | anti-affinity"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
RESULTS_DIR="$ROOT_DIR/results"

mkdir -p "$RESULTS_DIR"

echo "🚀 Rodando política: $POLICY"
echo "🧹 Limpando workloads anteriores..."
make -C "$ROOT_DIR" clean

echo "📦 Deployando..."
(
  cd "$ROOT_DIR/scripts"
  ./deploy-policy.sh "$POLICY"
)

STATUS_FILE="$RESULTS_DIR/${POLICY}-status.txt"
PODS_FILE="$RESULTS_DIR/${POLICY}-pods.txt"
PENDING_FILE="$RESULTS_DIR/${POLICY}-pending.txt"
EVENTS_FILE="$RESULTS_DIR/${POLICY}-events.txt"

echo "📊 Salvando pods por node -> $STATUS_FILE"
make -C "$ROOT_DIR" status | tee "$STATUS_FILE"

echo "🗒️ Listando pods completos -> $PODS_FILE"
kubectl get pods -l app=nginx-test -o wide | tee "$PODS_FILE"

echo "⏳ Checando pods Pending -> $PENDING_FILE"
kubectl get pods -l app=nginx-test -o wide --field-selector=status.phase=Pending | tee "$PENDING_FILE"

echo "🧾 Eventos recentes -> $EVENTS_FILE"
kubectl get events --sort-by='.lastTimestamp' | tail -n 30 | tee "$EVENTS_FILE"

echo ""
echo "✅ Concluído. Outputs em $RESULTS_DIR:"
ls -1 "$RESULTS_DIR" | sed 's/^/  - /'
