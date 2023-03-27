TAG=18

build:
	docker buildx build --platform linux/amd64,linux/arm64/v8 -t docker.io/enekofb/synthetic:$(TAG) -t docker.io/enekofb/synthetic:latest . --push

run-objective2: build
	docker run -it -e CYPRESS_WEGO_USERNAME=${CYPRESS_WEGO_USERNAME} -e CYPRESS_WEGO_PASSWORD=${CYPRESS_WEGO_PASSWORD} \
			docker.io/enekofb/synthetic:$(TAG) --spec "cypress/e2e/objective2/**/*"

run-objective3: build
	docker run -it -e CYPRESS_WEGO_USERNAME=${CYPRESS_WEGO_USERNAME} -e CYPRESS_WEGO_PASSWORD=${CYPRESS_WEGO_PASSWORD} \
		-e CYPRESS_LEAF_URL=${CYPRESS_LEAF_URL} -e CYPRESS_LEAF_TOKEN=${CYPRESS_LEAF_TOKEN} \
			docker.io/enekofb/synthetic:$(TAG) --spec "cypress/e2e/objective3/**/*"
