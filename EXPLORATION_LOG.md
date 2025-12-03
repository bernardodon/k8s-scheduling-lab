# Log de Exploração - K8s Scheduling Lab

**Período:** 03-07 Dezembro 2024
**Objetivo:** Explorar políticas de scheduling para definir tema de TCC

---

## 🎯 Motivação

Antes de definir tema específico do TCC, criar ambiente de experimentação funcional para:
- Entender diferenças práticas entre políticas
- Validar métricas mensuráveis
- Identificar perguntas de pesquisa interessantes
- Ter demonstração pronta para orientador

---

## 🛠️ Setup Inicial

### Ambiente
- **Cluster:** Kind v1.27.3
- **Nodes:** 1 control-plane + 4 workers
- **Monitoring:** kube-prometheus-stack (Prometheus + Grafana)
- **Workload:** Nginx customizado com labels
- **Host:** [preencher: CPU, RAM, OS]

### Instalação
```bash
make setup  # ~10min
make grafana  # port-forward
```

**Status:** ✅ Funcionou sem problemas

---

## 🧪 Experimentos Realizados

### Experimento 1: Default (Baseline)

**Data:** [preencher]

**Configuração:**
- 20 pods
- Sem políticas de scheduling
- Scheduler padrão decide

**Comando:**
```bash
./scripts/deploy-policy.sh default
```

**Resultado - Distribuição:**
```
[colar output do kubectl get pods -o wide]
```

**Pods por node:**
```
[colar saída do make status]
```

**Observações:**
- [anotar o que chamou atenção]
- [distribuição uniforme ou desbalanceada?]
- [algum node ficou sem pods?]

**Screenshot Grafana:**
`dashboards/screenshots/01-default.png`

---

### Experimento 2: Spreading (Distribuição Uniforme)

**Data:** [preencher]

**Configuração:**
- 20 pods
- TopologySpreadConstraints, maxSkew=1
- whenUnsatisfiable: ScheduleAnyway

**Comando:**
```bash
make clean
./scripts/deploy-policy.sh spreading
```

**Resultado - Distribuição:**
```
[colar output]
```

**Observações:**
- Distribuição foi realmente uniforme? (~5 pods/node)
- Diferença visível vs default?
- Tempo de scheduling notável?

**Screenshot Grafana:**
`dashboards/screenshots/02-spreading.png`

---

### Experimento 3: Anti-Affinity (Alta Disponibilidade)

**Data:** [preencher]

**Configuração:**
- 4 pods (limitado pelo número de nodes)
- Pod Anti-Affinity hard (required)
- Garante máximo 1 pod por node

**Comando:**
```bash
make clean
./scripts/deploy-policy.sh anti-affinity
```

**Resultado - Distribuição:**
```
[colar output]
```

**Observações:**
- Exatamente 1 pod por node? ✅
- Se aumentar réplicas pra 5, o 5º fica Pending?
- Limitação clara demonstrada?

**Screenshot Grafana:**
`dashboards/screenshots/03-anti-affinity.png`

**Teste adicional (opcional):**
```bash
# Editar deployment pra 5 réplicas
kubectl scale deployment nginx-test --replicas=5
kubectl get pods  # Ver 1 Pending
```

---

### Experimento 4: Pod Affinity (Concentração)

**Data:** [preencher]

**Configuração:**
- 20 pods
- Pod Affinity preferred (soft), weight=100
- Prefere nodes que já têm pods do app

**Comando:**
```bash
make clean
./scripts/deploy-policy.sh pod-affinity
```

**Resultado - Distribuição:**
```
[colar output]
```

**Observações:**
- Concentrou em 1-2 nodes?
- Ou distribuiu mais do que esperado?
- Diferença vs default é clara visualmente?

**Screenshot Grafana:**
`dashboards/screenshots/04-pod-affinity.png`

---

## 📊 Comparação Visual

| Política | Pods/Node (aprox) | Nodes Usados | Uniformidade |
|----------|-------------------|--------------|--------------|
| Default | [preencher] | [ex: 4/4] | [média/baixa/alta] |
| Spreading | ~5 por node | 4/4 | Alta |
| Anti-Affinity | 1 por node | 4/4 | Perfeita |
| Pod Affinity | [preencher] | [ex: 2/4] | Baixa |

---

## 💡 Descobertas

### Técnicas

1. **Anti-Affinity é limitado pelo número de nodes**
   - Constraint hard não negocia
   - Com 4 workers, máximo 4 pods
   - Pods extras ficam Pending (comportamento esperado)

2. **Pod Affinity não é binpacking real**
   - Simula comportamento via preferredDuringScheduling
   - Mas não é o plugin MostAllocated do scheduler
   - Concentra, mas não 100%

3. **Spreading funciona muito bem visualmente**
   - Diferença clara vs default
   - maxSkew=1 garante uniformidade
   - Métricas visuais são suficientes

4. **[Adicionar suas descobertas]**

### Métricas Viáveis

✅ **O que dá pra medir facilmente:**
- Pods por node (visual, claro)
- Nodes utilizados (eficiência)
- Pods Pending (limitações)
- Timeline de distribuição (Grafana)

⚠️ **O que seria mais trabalho:**
- StdDev matemático preciso
- Latência inter-pod
- Tempo de scheduling
- Métricas de resiliência (precisa simular falhas)

### Limitações do Setup

1. **Kind não é produção:**
   - Nodes são containers, não VMs
   - Recursos compartilhados com host
   - Métricas de CPU/RAM são aproximadas

2. **Escala pequena:**
   - 4 workers é suficiente pra demonstrar conceito
   - Mas não testa comportamento em escala (100+ nodes)

3. **Workload sintético:**
   - Nginx básico não simula padrões reais
   - Sem I/O, sem comunicação inter-pod
   - Mas serve pro propósito de visualizar distribuição

---

## 🤔 Perguntas para o Orientador (Giovanni)

### Sobre Escopo
1. Focar em **comparação visual** ou **análise quantitativa**?
2. 4 nodes é suficiente ou precisa escalar (ex: 10 nodes)?
3. Adicionar cenários de falha (simular node down)?

### Sobre Tema
1. **Opção A:** "Comparação empírica de políticas de scheduling"
   - Foco: Métricas, gráficos, análise
   - Rigor: Mais científico, precisa estatística

2. **Opção B:** "Playbook: Como escolher políticas baseado em requisitos"
   - Foco: Guia prático, trade-offs
   - Rigor: Mais engenharia, menos formal

3. **Opção C:** "Ferramenta de recomendação de política"
   - Foco: Implementação, automação
   - Rigor: Mais código, menos análise

Qual direção faz mais sentido pro TCC?

### Sobre Metodologia
1. Métricas atuais são suficientes?
2. Precisa de análise estatística formal (média, IC 95%)?
3. Quantas execuções por cenário? (atualmente 1, poderia ser 10+)

---

## 🎯 Possíveis Temas de TCC

### Tema 1: Análise Comparativa Quantitativa

**Título:** "Análise Comparativa de Políticas de Scheduling em Kubernetes: Estudo Empírico"

**Pergunta de pesquisa:**
- Como diferentes políticas afetam distribuição de pods?
- Quais trade-offs entre utilização de recursos e resiliência?

**Metodologia:**
- Ambiente controlado (Kind)
- 10+ execuções por cenário
- Análise estatística (média, desvio, IC)
- Métricas: distribuição, nodes usados, eficiência

**Pros:**
- Científico, publicável
- Métricas claras
- Reproduzível

**Contras:**
- Precisa rigor estatístico
- Mais trabalho em análise
- Menos aplicável à indústria

---

### Tema 2: Guia de Decisão (Playbook)

**Título:** "Playbook de Scheduling Kubernetes: Guia de Decisão Baseado em Requisitos"

**Pergunta de pesquisa:**
- Quando usar cada política?
- Quais os trade-offs práticos?
- Como escolher baseado em requisitos de negócio?

**Metodologia:**
- Cenários práticos (custo, HA, performance)
- Demonstrações visuais
- Análise qualitativa de trade-offs
- Guia de decisão estruturado

**Pros:**
- Útil pra indústria
- Demonstrável
- Menos rigor formal necessário

**Contras:**
- Menos científico
- Mais subjetivo
- Contribuição acadêmica menor

---

### Tema 3: Sistema de Recomendação

**Título:** "Sistema de Recomendação de Políticas de Scheduling Baseado em Características do Workload"

**Pergunta de pesquisa:**
- É possível automatizar escolha de política?
- Quais características do workload importam?
- Como criar ferramenta de apoio à decisão?

**Metodologia:**
- Classificação de workloads
- Modelo de decisão (regras ou ML)
- Implementação de CLI/webapp
- Validação com casos reais

**Pros:**
- Contribuição técnica clara
- Diferenciado
- Bom pra portfolio

**Contras:**
- Mais complexo
- Precisa validar modelo
- Risco de over-engineering

---

## 📅 Próximos Passos

- [ ] **Hoje (07/12):** Finalizar screenshots, exportar dashboard
- [ ] **08/12:** Email pro Giovanni com demo
- [ ] **Semana 09-13/12:** Reunião com orientador
- [ ] **Pausa dez:** Foco no novo emprego
- [ ] **Jan/2025:** Retomar com tema definido

---

## 📚 Leituras Realizadas

- [ ] "A survey of Kubernetes scheduling algorithms" (Journal of Cloud Computing, 2023)
- [ ] "Optimization of Task-Scheduling Strategy in Edge K8s" (MDPI, 2023)
- [ ] Docs oficiais: Topology Spread Constraints
- [ ] Docs oficiais: Pod Affinity/Anti-Affinity
- [ ] [Adicionar outros]

---

## 🔗 Links Úteis

- [Kubernetes Scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/)
- [Scheduler Plugins](https://github.com/kubernetes-sigs/scheduler-plugins)
- [KEP-895: TopologySpreadConstraints](https://github.com/kubernetes/enhancements/tree/master/keps/sig-scheduling/895-pod-topology-spread)

---

**Última atualização:** [data]
