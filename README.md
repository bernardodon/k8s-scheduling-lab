# K8s Scheduling Lab

Experimento que demonstra como a estratégia de scheduling afeta a capacidade real de um cluster Kubernetes.

## Início rápido

```bash
make setup    # Cria cluster + Prometheus/Grafana (~10min)
make run      # Roda o experimento
```

## Passo a passo manual

### 1. Pré-requisitos

- Docker
- [Kind](https://kind.sigs.k8s.io/) 
- kubectl
- Helm

### 2. Setup

```bash
make setup
```

Isso executa `scripts/setup.sh`, que:
- Cria cluster Kind com 4 workers
- Instala Prometheus + Grafana

### 3. Rodar experimento

```bash
make run
```

Isso executa `scripts/suite.sh`, que roda os três cenários e mostra o resumo.

Ou rodar manualmente:

```bash
# Cenário default (LeastAllocated)
kubectl apply -f workloads/filler-default.yaml
kubectl rollout status deployment/fragment-filler
kubectl apply -f workloads/big.yaml
kubectl get pods -l app=fragment-big   # Pending

# Limpar
kubectl delete deployment fragment-filler fragment-big

# Cenário spreading
kubectl apply -f workloads/filler-spread.yaml
kubectl rollout status deployment/fragment-filler
kubectl apply -f workloads/big.yaml
kubectl get pods -l app=fragment-big   # Pending

# Limpar
kubectl delete deployment fragment-filler fragment-big

# Cenário binpacking
kubectl apply -f workloads/filler-binpack.yaml
kubectl rollout status deployment/fragment-filler
kubectl apply -f workloads/big.yaml
kubectl get pods -l app=fragment-big   # Running
```

### 4. Ver Grafana (opcional)

```bash
make grafana
# Acesse http://localhost:3000 (admin/admin)
```

Query para ver pods por node:
```promql
count by (node) (kube_pod_info{namespace="default", pod=~"fragment-.*"})
```

## Resultados

| Estratégia | Mecanismo | Pod Grande |
|------------|-----------|------------|
| Default | Spreading via scoring (LeastAllocated) | **Pending** |
| Spread | Spreading via constraint (TopologySpreadConstraints) | **Pending** |
| Binpack | Concentração via afinidade (PodAffinity) | **Running** |

Ver `results/analise.md` para análise detalhada.

## Estrutura

```
├── Makefile
├── cluster.yaml              # Config Kind (1 control-plane + 4 workers)
├── scripts/
│   ├── setup.sh              # Cria cluster + monitoring
│   ├── suite.sh              # Roda os três cenários
│   ├── run-scenario.sh       # Roda um cenário
│   └── cleanup.sh            # Remove workloads
├── workloads/
│   ├── filler-default.yaml   # Sem constraints - spreading via LeastAllocated
│   ├── filler-spread.yaml    # Spreading via TopologySpreadConstraints
│   ├── filler-binpack.yaml   # Concentração via PodAffinity
│   └── big.yaml              # 1 pod de 6 vCPU
└── results/
    ├── default.txt           # Log cenário default
    ├── spread.txt            # Log cenário spreading
    ├── binpack.txt           # Log cenário binpacking
    └── analise.md            # Análise dos resultados
```

## Comandos

| Comando | Descrição |
|---------|-----------|
| `make setup` | Cria cluster + monitoring |
| `make run` | Executa experimento |
| `make clean` | Remove deployments |
| `make grafana` | Abre Grafana |
| `make destroy` | Deleta cluster |
