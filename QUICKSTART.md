# 🚀 Quick Start Guide

Guia rápido pra rodar o lab em 5 minutos.

---

## ✅ Pré-requisitos

```bash
# Verificar instalações
docker ps  # Docker rodando?
kind version
kubectl version --client
helm version
```

---

## 📦 Setup (primeira vez)

```bash
cd k8s-scheduling-lab

# 1. Criar cluster + instalar monitoring (~10min)
make setup

# Aguardar mensagem "✅ Setup completo!"
```

**Troubleshooting:**
- Se Kind falhar: `make destroy` e tente novamente
- Se Prometheus demorar: É normal, aguarde até 10min

---

## 🎨 Abrir Grafana

```bash
# Em OUTRO terminal
make grafana

# Acesse: http://localhost:3000
# Login: admin / admin
```

---

## 🧪 Rodar Experimentos

### Experimento 1: Spreading

```bash
./scripts/deploy-policy.sh spreading

# Ver distribuição
make status

# Resultado esperado: ~5 pods por node
```

### Experimento 2: Anti-Affinity

```bash
make clean  # Limpar anterior
./scripts/deploy-policy.sh anti-affinity

# Ver distribuição
make status

# Resultado esperado: 1 pod por node, 4 total
```

### Experimento 3: Default (Baseline)

```bash
make clean
./scripts/deploy-policy.sh default

make status

# Resultado esperado: Distribuição natural
```

---

## 📊 Ver no Grafana

1. Acesse http://localhost:3000
2. Dashboards → Browse → Import
3. Copiar conteúdo de `dashboards/scheduling-comparison.json`
4. Colar e Import
5. Ver visualizações em tempo real

**Ou criar dashboard manualmente:**
1. Create → Dashboard → Add visualization
2. Datasource: Prometheus
3. Query: `count by (node) (kube_pod_info{namespace="default", pod=~"nginx-test-.*"})`
4. Visualization: Bar chart

---

## 📸 Tirar Screenshots

```bash
# Deploy política
./scripts/deploy-policy.sh spreading

# Aguardar estabilizar (~30s)
kubectl get pods -l app=nginx-test -o wide

# No Grafana, tirar screenshot do dashboard
# Salvar em dashboards/screenshots/spreading.png

# Repetir para cada política
```

---

## 🧹 Limpar e Destruir

```bash
# Limpar workloads (cluster continua rodando)
make clean

# Deletar cluster inteiro
make destroy
```

---

## 🔧 Comandos Úteis

```bash
# Ver todos os comandos
make help

# Status rápido
make status

# Ver pods em tempo real
watch kubectl get pods -l app=nginx-test -o wide

# Ver logs do monitoring
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana

# Port-forward Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
```

---

## ❗ Troubleshooting

### Pods ficam Pending
- Ver motivo: `kubectl describe pod <pod-name>`
- Se for Anti-Affinity: É esperado se replicas > 4

### Grafana não abre
- Verificar port-forward: `kubectl get pods -n monitoring`
- Tentar: `kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring`

### Deployment não aplica
- Verificar política existe: `ls scheduling-policies/`
- Ver erro: `kubectl get events --sort-by='.lastTimestamp'`

### Cluster lento
- Kind compartilha recursos com host
- Fechar outros apps pesados
- Ou reduzir `values.yaml` do Prometheus

---

## 📋 Checklist Pós-Setup

- [ ] Cluster com 5 nodes (1 control + 4 workers)
- [ ] Monitoring namespace com pods Running
- [ ] Grafana acessível em localhost:3000
- [ ] Deploy de 1 política funciona
- [ ] `make status` mostra distribuição
- [ ] Screenshots salvos

---

## 🎯 Próximo: Reunião com Orientador

Preparar:
1. ✅ Lab funcionando
2. ✅ 3 políticas testadas
3. ✅ Screenshots de cada uma
4. ✅ EXPLORATION_LOG preenchido
5. ✅ Lista de perguntas pro orientador

---

**Dúvidas?** Ver [README.md](README.md) ou [EXPLORATION_LOG.md](EXPLORATION_LOG.md)
