# K8s Scheduling Exploration Lab

Lab local para explorar políticas de scheduling do Kubernetes.

## 🎯 Objetivo

Ambiente de experimentação para comparar diferentes estratégias de scheduling antes de definir tema específico de TCC.

## 🚀 Quick Start

```bash
# 1. Setup completo (cluster + monitoring)
make setup

# 2. Em outro terminal, abrir Grafana
make grafana

# 3. Acesse http://localhost:3000 (admin/admin)

# 4. Deploy uma política
./scripts/deploy-policy.sh spreading

# 5. Ver distribuição
make status
```

## 📦 O que tem aqui

- **Cluster Kind:** 1 control-plane + 4 workers
- **Monitoring:** Prometheus + Grafana (kube-prometheus-stack)
- **Workload:** Nginx customizado com info do pod
- **Políticas:** 4 estratégias de scheduling implementadas

## 🗂️ Estrutura

```
k8s-scheduling-lab/
├── cluster/              # Configuração do Kind
├── monitoring/           # Prometheus + Grafana
├── workloads/            # App de teste
├── scheduling-policies/  # 4 políticas implementadas
├── dashboards/           # Dashboard Grafana exportado
└── scripts/              # Scripts de deploy e coleta
```

## 📊 Políticas Implementadas

| Política | Mecanismo | Objetivo | Resultado Esperado |
|----------|-----------|----------|-------------------|
| **Default** | Scheduler padrão | Baseline | Distribuição natural |
| **Spreading** | TopologySpreadConstraints | Distribuir uniformemente | ~5 pods/node |
| **Anti-Affinity** | Pod Anti-Affinity (hard) | Alta disponibilidade | 1 pod/node, máx 4 |
| **Pod Affinity** | Pod Affinity (preferred) | Concentração | 1-2 nodes cheios |

## 🛠️ Comandos Úteis

```bash
make setup       # Cluster + monitoring
make grafana     # Port-forward Grafana
make status      # Ver distribuição atual
make clean       # Limpar workloads
make destroy     # Deletar cluster
```

## 📝 Requisitos

- Docker
- Kind
- kubectl
- Helm

## 🔍 Próximos Passos

- [ ] Reunião com orientador
- [ ] Definir tema específico de TCC
- [ ] Refinar metodologia
- [ ] Expandir experimentos

## 📖 Documentação

- [EXPLORATION_LOG.md](EXPLORATION_LOG.md) - Descobertas e observações
- [scheduling-policies/](scheduling-policies/) - Detalhes de cada política

---

**Status:** Exploração inicial (Dez/2024)
