# Template de Email para Giovanni

**Copiar e personalizar antes de enviar**

---

**Assunto:** TCC - Lab de exploração K8s scheduling pronto

---

Oi Giovanni,

Montei um lab Kubernetes local para explorar possibilidades de tema para o TCC.

## O que está pronto

- **Cluster Kind:** 1 control-plane + 4 workers
- **Monitoring:** Prometheus + Grafana configurados
- **4 políticas implementadas:**
  1. Default (baseline - scheduler padrão)
  2. Spreading (TopologySpreadConstraints - distribuição uniforme)
  3. Anti-Affinity (Pod Anti-Affinity hard - alta disponibilidade)
  4. Pod Affinity (concentração de pods - otimização de custo)

- **Visualização:** Dashboard Grafana comparando as políticas
- **Documentação:** README, log de exploração, guia de cada política

## Descobertas interessantes

[Preencher depois de rodar experimentos - exemplos:]

1. **Anti-Affinity tem limitação clara:** Com 4 workers, máximo 4 pods. Se colocar mais réplicas, ficam Pending. Isso demonstra trade-off entre HA e escalabilidade.

2. **Spreading funciona muito bem visualmente:** Distribuição fica uniforme (~5 pods/node com 20 réplicas). Diferença é clara vs scheduler padrão.

3. **Pod Affinity concentra, mas não 100%:** Simula binpacking, mas não é idêntico ao plugin MostAllocated. Comportamento é aproximado.

4. **[Adicionar sua 4ª descoberta]**

## Possíveis direções de tema

Trouxe 3 opções baseado no que consegui medir:

**1. Comparação Quantitativa**
- Título: "Análise Comparativa de Políticas de Scheduling em Kubernetes"
- Foco: Métricas, análise estatística, gráficos
- Pros: Científico, publicável
- Contras: Precisa rigor formal

**2. Guia de Decisão (Playbook)**
- Título: "Playbook de Scheduling K8s: Guia Baseado em Requisitos"
- Foco: Trade-offs práticos, quando usar cada política
- Pros: Útil pra indústria, demonstrável
- Contras: Menos rigor acadêmico

**3. Sistema de Recomendação**
- Título: "Sistema de Recomendação de Políticas de Scheduling"
- Foco: Ferramenta/CLI que sugere política baseado em requisitos
- Pros: Contribuição técnica, diferenciado
- Contras: Mais complexo

## Perguntas

1. Qual dessas direções você acha mais interessante/viável?
2. 4 nodes é suficiente ou precisa escalar ambiente?
3. Deveria adicionar cenários de falha (simular node down)?
4. Foco em análise quantitativa ou qualitativa?

## Demo

Podemos agendar uma call essa semana? Queria mostrar o lab funcionando e ver qual direção faz mais sentido pro TCC.

[Opcional: Se subiu no GitHub]
Repo: [link]

Abraço,
[Seu nome]

---

**Contexto adicional (se ele perguntar):**

- **Timeline:** Começo emprego novo dia 08/12. Fiz esse sprint de setup essa semana, vou pausar em dezembro pro onboarding, e retomo em janeiro.
- **Tempo investido:** ~12h em 5 dias (2-3h/dia)
- **Próximos passos:** Definir tema, refinar metodologia, expandir experimentos em janeiro

---

**Anexos sugeridos:**

- Screenshots das 4 políticas no Grafana
- Output do `make status` de cada política
- [Opcional] EXPLORATION_LOG.md
