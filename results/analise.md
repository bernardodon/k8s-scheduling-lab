# Análise do Experimento

## O que foi testado

Montei um cluster Kubernetes local com 4 nodes (usando Kind) pra testar como diferentes estratégias de scheduling afetam a capacidade real do cluster.

A ideia era simples: criar 4 pods "fillers" de 2.5 vCPU cada, e depois tentar agendar um pod grande de 6 vCPU. A pergunta era: a ordem e distribuição dos pods menores afeta se o pod grande consegue rodar?

## Os dois cenários

**Spreading (topologySpreadConstraints)**

Forcei os fillers a se espalharem pelos nodes. O resultado foi que cada node ficou com aproximadamente 2.5 vCPU ocupados. Quando tentei agendar o pod grande, ele ficou Pending - nenhum node tinha 6 vCPU livres, mesmo que a soma total de CPU livre no cluster fosse mais que suficiente.

**Binpacking (podAffinity)**

Usei afinidade pra fazer os fillers se agruparem nos mesmos nodes. Isso deixou pelo menos um node praticamente vazio. O pod grande conseguiu agendar sem problemas.

## Resultados

| Estratégia | Pod Grande |
|------------|------------|
| Spreading  | Pending    |
| Binpacking | Running    |

## O que isso significa

O scheduler do Kubernetes olha node por node, não olha a capacidade total do cluster. Então mesmo tendo CPU "sobrando" quando você soma tudo, se essa capacidade estiver fragmentada entre vários nodes, pods grandes não conseguem agendar.

Isso é o que a literatura chama de "capacidade fantasma" - parece que tem recurso disponível, mas na prática não tem.

Na prática, isso significa que a escolha entre spreading e binpacking não é só sobre resiliência vs custo. Também afeta se workloads maiores vão conseguir rodar ou não. Em clusters com mix de pods pequenos e grandes, binpacking tende a funcionar melhor pra evitar esse problema.
