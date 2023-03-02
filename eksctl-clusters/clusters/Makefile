#following https://docs.cilium.io/en/v1.13/observability/grafana/#install-metrics
#remember policy enforcement https://docs.cilium.io/en/v1.12/policy/intro/

all: cilium networking monitoring

cilium:
	cilium install --cluster-name=wge-2448 --helm-values cilium-values.yaml
	cilium hubble enable #i think this should not be needed but does not seem to work hubble without

networking:
	kubectl apply -f netwoking.yaml

monitoring:
	kubectl apply -f monitoring/

uninstall:
	cilium uninstall
	kubectl delete -f netwoking.yaml || true
	kubectl delete -f monitoring/

leaf:
	kubectl apply -f clusters.yaml
	kubectl create secret -n flux-system generic leaf-cluster-1-kubeconfig --from-file=value=/Users/enekofb/projects/github.com/enekofb/weaveworks/pocs/observability/secrets/kubeconfig.yaml
