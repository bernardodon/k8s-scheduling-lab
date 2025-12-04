# Políticas de Scheduling

3 estratégias implementadas para comparação.

## 📋 Visão Geral

| Política | Arquivo | Mecanismo | Réplicas | Resultado Esperado |
|----------|---------|-----------|----------|-------------------|
| **Default** | `1-default/` | Scheduler padrão | 20 | Distribuição natural |
| **Spreading** | `2-spreading/` | TopologySpreadConstraints | 20 | ~5 pods/node |
| **Anti-Affinity** | `3-anti-affinity/` | Pod Anti-Affinity (hard) | 4 | 1 pod/node |

---

## 1️⃣ Default (Baseline)

**Arquivo:** `1-default/deployment.yaml`

**Comportamento:**
- Sem políticas de scheduling
- Scheduler padrão do K8s decide
- Balanceamento básico considerando recursos

**Objetivo:**
- Baseline para comparação
- Ver comportamento "natural" do scheduler

**Resultado esperado:**
- Distribuição razoável mas não uniforme
- Tende a equilibrar recursos

---

## 2️⃣ Spreading (Distribuição Uniforme)

**Arquivo:** `2-spreading/deployment.yaml`

**Mecanismo:**
```yaml
topologySpreadConstraints:
- maxSkew: 1
  topologyKey: kubernetes.io/hostname
  whenUnsatisfiable: ScheduleAnyway
```

**Comportamento:**
- Garante diferença máxima de 1 pod entre nodes
- `ScheduleAnyway` = flexível, não trava

**Objetivo:**
- Balanceamento de carga
- Evitar hotspots
- Usar todos os nodes uniformemente

**Resultado esperado:**
- 20 pods / 4 workers = 5 pods por node
- Distribuição visual clara

**Caso de uso real:**
- APIs stateless
- Workers de background
- Aplicações que precisam distribuir carga

---

## 3️⃣ Anti-Affinity (Alta Disponibilidade)

**Arquivo:** `3-anti-affinity/deployment.yaml`

**Mecanismo:**
```yaml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        policy: anti-affinity
    topologyKey: kubernetes.io/hostname
```

**Comportamento:**
- **HARD constraint:** NUNCA dois pods no mesmo node
- `required` = obrigatório, não negociável

**Objetivo:**
- Alta disponibilidade
- Tolerância a falha de node
- Isolamento máximo

**Resultado esperado:**
- Máximo 4 pods (1 por worker)
- **Limitação documentada:** Mais réplicas ficam Pending

**Caso de uso real:**
- Bancos de dados (replicas)
- Redis/Memcached clusters
- Aplicações críticas

**⚠️ Importante:**
- Com 4 workers, máximo 4 pods
- Se `replicas > 4`, os extras ficam Pending
- Isso é comportamento esperado e demonstra limitação real

---

## 🚀 Como Usar

```bash
# Deploy uma política
cd k8s-scheduling-lab
./scripts/deploy-policy.sh spreading

# Ver distribuição
make status

# Limpar
make clean

# Testar outra
./scripts/deploy-policy.sh anti-affinity
```

---

## 📊 Comparação Rápida

### Distribuição de Pods
- **Default:** Natural (~4-6 por node)
- **Spreading:** Uniforme (5 por node)
- **Anti-Affinity:** Isolado (1 por node)

### Utilização de Nodes
- **Default:** 4/4 nodes
- **Spreading:** 4/4 nodes
- **Anti-Affinity:** 4/4 nodes (forçado)

### Trade-offs

| Política | ✅ Vantagem | ❌ Desvantagem |
|----------|-----------|--------------|
| **Spreading** | Balanceamento, resiliência | Usa todos os nodes (custo) |
| **Anti-Affinity** | HA máxima | Limita escalabilidade |

---

## 🔍 Próximos Passos

- [ ] Adicionar métricas de latência inter-pod
- [ ] Testar com diferentes números de réplicas
- [ ] Simular falha de node
- [ ] Medir tempo de scheduling
- [ ] Comparar com scheduler customizado

---

## 📚 Referências

- [Topology Spread Constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/)
- [Pod Affinity/Anti-Affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
- [Scheduling Policies](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)
