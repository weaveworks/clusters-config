TAG=13

build:
	docker buildx build --platform linux/amd64,linux/arm64/v8 -t docker.io/enekofb/synthetic:$(TAG) -t docker.io/enekofb/synthetic:latest . --push

run-wge: build
	docker run -it -e CYPRESS_WEGO_USERNAME=${CYPRESS_WEGO_USERNAME} \
	-e CYPRESS_WEGO_PASSWORD=${CYPRESS_WEGO_PASSWORD} docker.io/enekofb/synthetic:$(TAG) -P wge

run-meilisearch: build
	docker run -it docker.io/enekofb/synthetic:$(TAG) -P meilisearch -c baseUrl=http://host.docker.internal:7700

run-cypress-wge:
	cd wge && npx cypress open