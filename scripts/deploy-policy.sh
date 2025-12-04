#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

POLICY=$1

if [ -z "$POLICY" ]; then
    echo "Uso: ./deploy-policy.sh <policy-name>"
    echo ""
    echo "Políticas disponíveis:"
    echo "  default"
    echo "  spreading"
    echo "  anti-affinity"
    exit 1
fi

case "$POLICY" in
    default) POLICY_DIR="$ROOT_DIR/scheduling-policies/1-default" ;;
    spreading) POLICY_DIR="$ROOT_DIR/scheduling-policies/2-spreading" ;;
    anti-affinity) POLICY_DIR="$ROOT_DIR/scheduling-policies/3-anti-affinity" ;;
    *)
        echo "❌ Política '$POLICY' não reconhecida. Use: default | spreading | anti-affinity"
        exit 1
        ;;
esac

if [ ! -d "$POLICY_DIR" ]; then
    echo "❌ Política '$POLICY' não encontrada em $POLICY_DIR"
    exit 1
fi

echo "📦 Deployando política: $POLICY"

# Limpar workloads anteriores
echo "🧹 Limpando workloads anteriores..."
kubectl delete deployment,service,configmap -l app=nginx-test --ignore-not-found > /dev/null 2>&1

# Aguardar limpeza
sleep 3

# Aplicar ConfigMap
echo "📝 Aplicando ConfigMap..."
kubectl apply -f "$ROOT_DIR/workloads/nginx-test/configmap.yaml"

# Substituir variáveis no ConfigMap
echo "🔧 Injetando variáveis no HTML..."
kubectl get configmap nginx-test-html -o yaml | \
    sed "s/POLICY_NAME/$POLICY/g" | \
    kubectl apply -f -

# Aplicar política
echo "🚀 Aplicando deployment com política $POLICY..."
kubectl apply -f "$POLICY_DIR/deployment.yaml"

# Aguardar pods
echo "⏳ Aguardando pods ficarem Ready..."
kubectl wait --for=condition=Ready pod -l app=nginx-test --timeout=120s 2>/dev/null || true

# Mostrar distribuição
echo ""
echo "📊 Distribuição atual:"
kubectl get pods -l app=nginx-test -o wide --no-headers | \
    awk '{print $7}' | sort | uniq -c | sort -rn

echo ""
echo "✅ Deploy concluído!"
echo ""
echo "Ver detalhes: make status"
echo "Ver no Grafana: make grafana"
