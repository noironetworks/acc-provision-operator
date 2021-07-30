IMG ?= acc-provision-operator:latest
docker-build: ## Build docker image with the manager.
	docker build -t ${IMG} .
