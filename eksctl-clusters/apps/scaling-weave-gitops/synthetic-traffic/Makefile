build:
	docker buildx build --platform linux/amd64,linux/arm64/v8 -t docker.io/enekofb/synthetic:8 -t docker.io/enekofb/synthetic:latest . --push

run-wge:
	docker run -it -w /e2e/wge -e CYPRESS_WEGO_USERNAME=${CYPRESS_WEGO_USERNAME} \
	-e CYPRESS_WEGO_PASSWORD=${CYPRESS_WEGO_PASSWORD} docker.io/enekofb/synthetic:8

run-meilisearch:
	docker run -it -w /e2e/meilisearch docker.io/enekofb/synthetic:8