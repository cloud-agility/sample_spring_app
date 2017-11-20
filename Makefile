NAME		= spring-sample
ifndef TAGS
	TAGS	= local
else
	TAGS :=$(subst /,-,$(TAGS))
endif
DOCKER_IMAGE	= $(NAME):$(TAGS)

ifndef REGISTRY
# use minikube by default
	REGISTRY	= 192.168.99.100:32767/default
	REGISTRY_SECRET = $(shell kubectl get secret | grep default | awk '{print $$1}')
endif

ifndef RELEASE
	NAMESPACE = staging-$(TAGS)
	NAMESPACE :=$(subst .,-,$(NAMESPACE))
else
	NAMESPACE = production
endif

# COMMAND DEFINITIONS
BUILD		= docker build -t
TEST		= docker run --rm
TEST_CMD	= mvn test
TEST_DIR	= src
VOLUME		= -v$(CURDIR)/$(TEST_DIR):/usr/app/src
DEPLOY		= helm
LOGIN		= docker login
PUSH		= docker push
TAG		= docker tag

.PHONY: all
all: build unittest

.PHONY: build
build: Dockerfile
	echo ">> building app as $(DOCKER_IMAGE)"
	$(BUILD) $(DOCKER_IMAGE) .
	echo ">> packaging the $(DEPLOY) charts"
	$(DEPLOY) lint $(NAME)-chart
	$(DEPLOY) package $(NAME)-chart

.PHONY: unittest
unittest:
	echo ">> running tests on $(DOCKER_IMAGE)"
	$(TEST) $(VOLUME) $(DOCKER_IMAGE) $(TEST_CMD)

.PHONY: push
push:
ifneq ($(TAGS),$(RELEASE))
	echo ">> using $(REGISTRY) registry"
	$(TAG) $(DOCKER_IMAGE) $(REGISTRY)/$(DOCKER_IMAGE)
	$(PUSH) $(REGISTRY)/$(DOCKER_IMAGE)
else
	echo ">> pushing release $(RELEASE) image to docker hub as $(DOCKER_IMAGE)"
	$(LOGIN) -u="$(DOCKER_USERNAME)" -p="$(DOCKER_PASSWORD)"
	$(PUSH) $(DOCKER_IMAGE)
endif

.PHONY: namespace
namespace:
ifneq ($(NAMESPACE),"production")
	echo "Creating namespace $(NAMESPACE) with registry secret $(REGISTRY_SECRET)"
	kubectl create ns $(NAMESPACE)
	kubectl get secret $(REGISTRY_SECRET) -o json --namespace default | sed 's/"namespace": "default"/"namespace": "$(NAMESPACE)"/g' | kubectl create -f -
	kubectl patch sa default -p '{"imagePullSecrets": [{"name": "$(REGISTRY_SECRET)"}]}' --namespace $(NAMESPACE)
endif

.PHONY: deploy
deploy: push namespace
	echo ">> Use $(DEPLOY) to install $(NAME)-chart"
	## Override the values.yaml with the target
	$(DEPLOY) install $(NAME)-chart --set image.repository=$(REGISTRY),image.name=$(NAME) --namespace $(NAMESPACE) --name $(NAME) --wait

.PHONY: cleankube
cleankube:
	echo ">> cleaning kube cluster for namespace $(NAMESPACE)"
	$(DEPLOY) delete $(NAME) --purge
	kubectl delete namespace $(NAMESPACE)
