.PHONY: setup cluster monitoring grafana deploy-% clean status destroy help

CLUSTER_NAME := scheduling-lab

## Setup completo (cluster + monitoring)
setup: cluster monitoring
	@echo ""
	@echo "✅ Setup completo!"
	@echo ""
	@echo "Próximos passos:"
	@echo "  1. Em outro terminal: make grafana"
	@echo "  2. Acesse http://localhost:3000 (admin/admin)"
	@echo "  3. Deploy uma política: ./scripts/deploy-policy.sh spreading"

## Criar cluster Kind
cluster:
	@cd cluster && ./setup.sh

## Instalar Prometheus + Grafana
monitoring:
	@cd monitoring && ./install.sh

## Port-forward do Grafana
grafana:
	@echo "🔗 Abrindo Grafana em http://localhost:3000"
	@echo "Login: admin / admin"
	@kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

## Deploy política específica (ex: make deploy-spreading)
deploy-%:
	@./scripts/deploy-policy.sh $*

## Limpar workloads
clean:
	@echo "🧹 Limpando workloads..."
	@kubectl delete deployment,service,configmap -l app=nginx-test --ignore-not-found
	@echo "✅ Limpo!"

## Ver status de pods por node
status:
	@echo "📊 Pods por node:"
	@kubectl get pods -l app=nginx-test -o wide --no-headers 2>/dev/null | \
		awk '{print $$7}' | sort | uniq -c | sort -rn || echo "Nenhum pod deployado"
	@echo ""
	@echo "📋 Todos os pods:"
	@kubectl get pods -l app=nginx-test -o wide 2>/dev/null || echo "Nenhum pod deployado"

## Deletar cluster
destroy:
	@echo "💥 Deletando cluster..."
	@kind delete cluster --name $(CLUSTER_NAME)
	@echo "✅ Cluster deletado!"

## Ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make setup       - Criar cluster + instalar monitoring"
	@echo "  make cluster     - Apenas criar cluster Kind"
	@echo "  make monitoring  - Apenas instalar monitoring"
	@echo "  make grafana     - Port-forward do Grafana"
	@echo "  make deploy-*    - Deploy política (ex: deploy-spreading)"
	@echo "  make status      - Ver distribuição de pods"
	@echo "  make clean       - Limpar workloads"
	@echo "  make destroy     - Deletar cluster"
