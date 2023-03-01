#following https://docs.cilium.io/en/v1.13/observability/grafana/#install-metrics
#remember policy enforcement https://docs.cilium.io/en/v1.12/policy/intro/

all: cilium networking monitoring

cilium:
	cilium install --cluster-name=wge-2448 --helm-values cilium-values.yaml
	cilium hubble enable #i think this should not be needed but does not seem to work hubble without

networking:
	kubectl apply -f netwoking.yaml

monitoring:
	kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/master/examples/kubernetes/addons/prometheus/monitoring-example.yaml

uninstall:
	cilium uninstall
	kubectl delete -f netwoking.yaml || true
	kubectl delete -f https://raw.githubusercontent.com/cilium/cilium/master/examples/kubernetes/addons/prometheus/monitoring-example.yaml || true

add-repos:
	helm repo add cilium https://helm.cilium.io
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm repo add minio https://operator.min.io
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add strimzi https://strimzi.io/charts
	helm repo add elastic https://helm.elastic.co