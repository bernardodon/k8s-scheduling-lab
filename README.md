# K8s Scheduling Lab

Experimento prático que demonstra como a estratégia de scheduling afeta a capacidade real de um cluster Kubernetes.

## Passo a passo

### 1. Pré-requisitos

```bash
# Instalar Docker
# https://docs.docker.com/get-docker/

# Instalar Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Instalar Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2. Criar o cluster

```bash
kind create cluster --config cluster.yaml
```

Isso cria um cluster com 1 control-plane e 4 workers.

### 3. Instalar monitoramento (opcional)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set alertmanager.enabled=false \
  --set grafana.adminPassword=admin
```

Para acessar o Grafana:
```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
# Acesse http://localhost:3000 (admin/admin)
```

### 4. Rodar o experimento

```bash
make run
```

Ou manualmente:

```bash
# Cenário 1: Spreading
kubectl apply -f workloads/filler-spread.yaml
kubectl rollout status deployment/fragment-filler
kubectl apply -f workloads/big.yaml
kubectl get pods -l app=fragment-big   # Deve mostrar Pending

# Limpar
kubectl delete deployment fragment-filler fragment-big

# Cenário 2: Binpacking  
kubectl apply -f workloads/filler-binpack.yaml
kubectl rollout status deployment/fragment-filler
kubectl apply -f workloads/big.yaml
kubectl get pods -l app=fragment-big   # Deve mostrar Running
```

### 5. Verificar resultados

```bash
cat results/spread.txt    # Log do cenário spreading
cat results/binpack.txt   # Log do cenário binpacking
cat results/analise.md    # Análise dos resultados
```

## O problema: Capacidade Fantasma

O scheduler do Kubernetes avalia cada node individualmente. Um pod pode não agendar mesmo quando a soma de recursos livres é suficiente.

| Estratégia | Distribuição | Pod Grande | Motivo |
|------------|--------------|------------|--------|
| Spreading | 1 filler por node | **Pending** | Cada node tem ~5 vCPU livre (< 6) |
| Binpacking | Fillers concentrados | **Running** | Um node fica com ~7 vCPU livre |

## Estrutura

```
├── scripts/
│   ├── setup.sh          # Cria cluster + monitoring
│   ├── suite.sh          # Roda ambos cenários
│   ├── run-scenario.sh   # Roda um cenário específico
│   └── cleanup.sh        # Remove workloads
├── workloads/
│   ├── filler-spread.yaml    # Usa topologySpreadConstraints
│   ├── filler-binpack.yaml   # Usa podAffinity
│   └── big.yaml              # Pod de 6 vCPU
├── results/
│   └── analise.md        # Análise escrita
└── cluster.yaml          # Config do Kind (4 workers)
```

## Comandos make

| Comando | Descrição |
|---------|-----------|
| `make setup` | Cria cluster + Prometheus/Grafana |
| `make run` | Executa experimento completo |
| `make clean` | Remove deployments de teste |
| `make grafana` | Abre Grafana (localhost:3000) |
| `make destroy` | Deleta o cluster |

## Query Grafana

```promql
count by (node) (kube_pod_info{namespace="default", pod=~"fragment-.*"})
```
