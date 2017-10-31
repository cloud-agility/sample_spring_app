NAME		= spring_sample
ifndef TAGS
	TAGS	= local
else
	TAGS := $(subst /,-,$(TAGS))
endif
DOCKER_IMAGE	= $(NAME):$(TAGS)
DEPLOYMENT	= kubernetes/deployment.yaml
SERVICE		= kubernetes/service.yaml

#LOCAL		= icp
#REGISTRY	= mycluster.icp:8500/default
LOCAL		= minikube
REGISTRY	= 192.168.99.100:32767

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
	echo ">> deploying app to local $(LOCAL) cluster"
	$(DEPLOY) -f $(DEPLOYMENT)
	$(DEPLOY) -f $(SERVICE)
else
	echo ">> deploying app $(TAGS) to production (TODO)"
	#$(DEPLOY) -f $(DEPLOYMENT)
	#$(DEPLOY) -f $(SERVICE)
endif
