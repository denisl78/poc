# Makefile
K3S_VERSION ?= v1.30.6-k3s1
K3S_IMAGE_NAME := k3s-service
VALIDATOR_VERSION := $(shell git describe --tags --always --abbrev=24)
VALIDATOR_IMAGE_NAME := token-validator

$(info $$(K3S_VERSION) is [${K3S_VERSION}])

.PHONY: all
all:
	$(MAKE) token-validator-build
	$(MAKE) build-k3s-alpine
	$(MAKE) k3s-start
	$(MAKE) k3s-kubeconfig
	$(MAKE) deploy-argo
	$(MAKE) deploy-prometheus
	$(MAKE) deploy-grafana
	$(MAKE) deploy-podinfo
	$(MAKE) token-validator-publish
	$(MAKE) deploy-token-validator

.PHONY: clean
clean: k3s-stop

### Build contract ###
.PHONY: k3s-build
k3s-build: build-k3s-alpine
	docker build --rm \
                --build-arg K3S_VERSION="$(subst -,+,$(K3S_VERSION))" \
                -t "$(K3S_IMAGE_NAME):$(K3S_VERSION)" -f k3s/Dockerfile.alpine k3s/

.PHONY: build-k3s-alpine
build-k3s-alpine: $(IMAGE_K3S_ALPINE)

.PHONY: token-validator-build
token-validator-build:
	docker build \
                -t "$(VALIDATOR_IMAGE_NAME):$(VALIDATOR_VERSION)" \
		-f token-validator/Dockerfile token-validator/

.PHONY: token-validator-publish
token-validator-publish: token-validator-build
	@skopeo copy --dest-no-creds --dest-tls-verify=false \
		docker-daemon:$(VALIDATOR_IMAGE_NAME):$(VALIDATOR_VERSION) \
		docker://$(K3S_SERVICE_HOST):5000/$(VALIDATOR_IMAGE_NAME):$(VALIDATOR_VERSION)
	@skopeo copy --dest-no-creds --dest-tls-verify=false \
                docker-daemon:$(VALIDATOR_IMAGE_NAME):$(VALIDATOR_VERSION) \
                docker://$(K3S_SERVICE_HOST):5000/$(VALIDATOR_IMAGE_NAME):latest

K3S_SERVICE_NAME ?= k3s-service
export K3S_SERVICE_NAME
ifneq (, $(shell which docker))
K3S_SERVICE_RUN=$(shell docker ps -a --filter name=$(K3S_SERVICE_NAME) --format={{.Names}})
export K3S_SERVICE_RUN
$(info $$(K3S_SERVICE_RUN) is [${K3S_SERVICE_RUN}])
ifneq ($(K3S_SERVICE_RUN),)
K3S_SERVICE_HOST := $(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(K3S_SERVICE_RUN))
$(info $$(K3S_SERVICE_HOST) is [${K3S_SERVICE_HOST}])
export K3S_SERVICE_HOST
endif
endif

K3S_SERVICE_PORT := 18081
K3S_REGISTRY_PORT := 5000
K3S_SERVICE_PORTS := 6443:6443 ${K3S_SERVICE_PORT}:${K3S_SERVICE_PORT} \
        $(K3S_REGISTRY_PORT):$(K3S_REGISTRY_PORT) \
        $(K3S_CUSTOM_PORTS)

.PHONY: k3s-start
k3s-start:
ifneq ($(K3S_SERVICE_RUN),$(K3S_SERVICE_NAME))
	@docker run -d -p 6443:6443 -p 18081:18081 -p 5000:5000	\
		-e DOCKER_REGISTRY_HOST \
		--tmpfs /run --tmpfs /var/run \
		--privileged \
		--shm-size=2g \
		--name $(K3S_SERVICE_NAME) $(K3S_SERVICE_NAME):$(K3S_VERSION)
#	@sleep 10
endif

KUBECONFIG_FILE ?= $(PWD)/envs/k3s/k3s.yaml

.PHONY: k3s-kubeconfig
k3s-kubeconfig: k3s-start
	K3S_SERVICE_HOST=$(shell docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(K3S_SERVICE_RUN))
	while [ "$$(curl -s -o /dev/null -w ''%{http_code}'' http://$(K3S_SERVICE_HOST):$(K3S_SERVICE_PORT)/k3s.yaml)" != "200" ];do sleep 3;done;
	curl $(K3S_SERVICE_HOST):$(K3S_SERVICE_PORT)/k3s.yaml -o $(KUBECONFIG_FILE);
	sed -i "s/127.0.0.1/$(K3S_SERVICE_HOST)/g" $(KUBECONFIG_FILE);
	@echo Run:
	export KUBECONFIG=$(KUBECONFIG_FILE)
k3s-stop:
ifneq ($(K3S_SERVICE_RUN),)
	@docker rm -f $(K3S_SERVICE_RUN)
endif

# Application deploy
# Argo
.PHONY: deploy-argo
deploy-argo: k3s-kubeconfig
	@terraform -chdir=terraform/ init
	@terraform -chdir=terraform/ apply -auto-approve

.PHONY: deploy-prometheus
deploy-prometheus:
	@kubectl apply -f argocd/k3s/prometheus/release.yaml

.PHONY: deploy-grafana
deploy-grafana:
	@kubectl apply -f argocd/k3s/grafana/release.yaml

.PHONY: deploy-podinfo
deploy-podinfo:
	@kubectl apply -f argocd/k3s/podinfo/release.yaml

.PHONY: deploy-token-validator
deploy-token-validator:
	@kubectl apply -f token-validator/release.yaml
