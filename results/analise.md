# Análise

Criei um cluster Kind com 4 workers (~7 vCPU cada) pra testar como o scheduling afeta a capacidade real.

O experimento: primeiro aplico 4 pods "fillers" de 2.5 vCPU, depois tento agendar um pod grande de 6 vCPU.

## Os 3 cenários

Todos testam a mesma coisa: como a distribuição dos fillers afeta se o pod grande consegue rodar. A diferença é o mecanismo usado pra conseguir essa distribuição.

**Spreading via scoring (LeastAllocated)** - cenário "default"

Sem nenhum constraint. O scheduler usa a política padrão LeastAllocated, que dá mais pontos pra nodes menos ocupados. O efeito é spreading natural - cada filler vai pro node mais vazio no momento.

**Spreading via constraint (TopologySpreadConstraints)** - cenário "spread"

Constraint explícito que força distribuição entre nodes. Diferente do scoring, aqui é uma regra declarativa: "maxSkew: 1" significa no máximo 1 pod de diferença entre nodes.

**Binpacking via afinidade (PodAffinity)** - cenário "binpack"  

Afinidade entre pods do mesmo app. Cada novo filler prefere ir pro node que já tem outros fillers. O efeito é concentração.

## Resultados

```
Default (spreading via scoring):
  Fillers: worker, worker2, worker3, worker4
  Pod grande: Pending

Spread (spreading via constraint):
  Fillers: worker, worker2, worker3, worker4  
  Pod grande: Pending

Binpack (concentração via afinidade):
  Fillers: worker2, worker2, worker2, worker4
  Pod grande: Running
```

## O que isso mostra

Os dois primeiros cenários chegam no mesmo resultado (spreading) por mecanismos diferentes. Um é comportamento emergente do scoring, outro é constraint explícito.

O total de CPU livre no cluster era o mesmo nos 3 casos (~18 vCPU). Mas no spreading essa capacidade estava fragmentada - ~4.5 vCPU em cada node. No binpacking, ficou concentrada - nodes inteiros livres.

O scheduler do Kubernetes não olha capacidade agregada do cluster, olha node por node. Então capacidade "existe" mas não é utilizável por pods grandes. Isso é o que chamam de capacidade fantasma.
