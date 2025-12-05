.PHONY: setup run clean grafana destroy

setup:
	@./scripts/setup.sh

run:
	@./scripts/suite.sh

clean:
	@./scripts/cleanup.sh

grafana:
	@kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring

destroy:
	@kind delete cluster --name scheduling-lab
