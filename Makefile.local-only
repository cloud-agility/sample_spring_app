NAME		= spring_sample
ifndef TAGS
	TAGS	= local
else
	TAGS := $(subst /,-,$(TAGS))
endif
DOCKER_IMAGE	= $(NAME):$(TAGS)
DEPLOYMENT	= kubernetes/deployment.yaml
SERVICE		= kubernetes/service.yaml

#REGISTRY	= mycluster.icp:8500/default
REGISTRY	= 192.168.99.100:32767
#REGISTRY	= registry.eu-gb.bluemix.net/cloud_native_agility_staging

# COMMAND DEFINITIONS
BUILD		= docker build -t
TEST		= docker run --rm
TEST_CMD	= mvn test
TEST_DIR	= src
VOLUME		= -v $(CURDIR)/$(TESTDIR):/usr/app/src
DEPLOY		= kubectl apply
LOGIN		= docker login
PUSH		= docker push
TAG		= docker tag

.PHONY: all
all: build test

.PHONY: build
build: Dockerfile
	echo ">> building app as $(DOCKER_IMAGE)"
	$(BUILD) $(DOCKER_IMAGE) .

.PHONY: test
test:
	echo ">> running tests on $(DOCKER_IMAGE)"
	$(TEST) $(VOLUME) $(DOCKER_IMAGE) $(TEST_CMD)

.PHONY: push
push:
ifeq ($(TAGS),local)
	echo ">> using $(REGISTRY) registry"
	$(TAG) $(DOCKER_IMAGE) $(REGISTRY)/$(DOCKER_IMAGE)
	$(PUSH) $(REGISTRY)/$(DOCKER_IMAGE)
else
	echo ">> pushing image to docker hub as $(DOCKER_IMAGE)"
	$(LOGIN) -u="$(DOCKER_USERNAME)" -p="$(DOCKER_PASSWORD)"
	$(PUSH) $(DOCKER_IMAGE)
endif

.PHONY: deploy
deploy: push
ifeq ($(TAGS),local)
	echo ">> deploying app to local cluster"
	$(DEPLOY) -f $(DEPLOYMENT)
	$(DEPLOY) -f $(SERVICE)
else
	echo ">> deploying app $(TAGS) to production (TODO)"
	#$(DEPLOY) -f $(DEPLOYMENT)
	#$(DEPLOY) -f $(SERVICE)
endif

.PHONY: helm
helm: push
	echo ">> Use helm to install $(NAME)-chart"
	## Do something like this:
	helm lint $(NAME)-chart
	helm package $(NAME)-chart
	## Override the values.yaml with the target
	helm install $(NAME)-chart --set image.repository=$(REGISTRY)
