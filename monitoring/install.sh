#!/bin/bash
set -e

echo "📊 Instalando Prometheus + Grafana..."

# Adicionar repo do Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Criar namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Instalar kube-prometheus-stack
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values.yaml \
  --wait \
  --timeout 10m

# Aguardar pods ficarem prontos
echo ""
echo "⏳ Aguardando pods do monitoring..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s

echo ""
echo "✅ Monitoring instalado!"
echo ""
echo "Para acessar o Grafana, rode em outro terminal:"
echo "  kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
echo ""
echo "Ou use: make grafana"
echo ""
echo "Login: admin / admin"
