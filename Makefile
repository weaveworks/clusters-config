.PHONY: default \
		request-cluster \
		update-cluster \
		provision-cluster \
		help

ARGS := $*

##@ Default
default: help ## Run make help

##@ Cluster
request-cluster: ## Request a cluster.
	@./eksctl-clusters/scripts/request-cluster.sh $(ARGS)

update-cluster: ## Update a cluster.
	@./eksctl-clusters/scripts/update-cluster.sh $(ARGS)

provision-cluster: ## Provision a cluster.
	@./eksctl-clusters/scripts/provision-cluster.sh $(ARGS)

extend-ttl: ## Extend cluster ttl.
	@./eksctl-clusters/scripts/extend-cluster-ttl.sh $(ARGS)

##@ Utilities
# Thanks to https://www.thapaliya.com/en/writings/well-documented-makefiles/
help:  ## Display this help.
ifeq ($(OS),Windows_NT)
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n make <target>\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-40s %s\n", $$1, $$2 } /^##@/ { printf "\n%s\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
else
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
endif
