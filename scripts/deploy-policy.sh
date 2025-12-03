#!/bin/bash
set -e

POLICY=$1

if [ -z "$POLICY" ]; then
    echo "Uso: ./deploy-policy.sh <policy-name>"
    echo ""
    echo "Políticas disponíveis:"
    echo "  default"
    echo "  spreading"
    echo "  anti-affinity"
    echo "  pod-affinity"
    exit 1
fi

POLICY_DIR="../scheduling-policies/$POLICY"

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
kubectl apply -f ../workloads/nginx-test/configmap.yaml

# Substituir variáveis no ConfigMap
echo "🔧 Injetando variáveis no HTML..."
kubectl get configmap nginx-test-html -o yaml | \
    sed "s/POLICY_NAME/$POLICY/g" | \
    kubectl apply -f -

# Aplicar política
echo "🚀 Aplicando deployment com política $POLICY..."
kubectl apply -f $POLICY_DIR/deployment.yaml

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
