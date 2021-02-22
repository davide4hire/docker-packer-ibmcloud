##################################################
# Your Project's Custom Properties               #
##################################################

VersionFile    = ./version.sh
VERSION       := $(shell source $(VersionFile); echo $$VERSION)
RELEASE       := $(shell source $(VersionFile); echo $$RELEASE)
PACKER_CONTAINER_URL     := $(shell source $(VersionFile); echo $$PACKER_CONTAINER_URL)
PACKER_CONTAINER_VERSION := $(shell source $(VersionFile); echo $$PACKER_CONTAINER_VERSION)
PLUGIN_GIT_URL := $(shell source $(VersionFile); echo $$PLUGIN_GIT_URL)
PLUGIN_VERSION := $(shell source $(VersionFile); echo $$PLUGIN_VERSION)
PLUGIN_SHA     := $(shell source $(VersionFile); echo $$PLUGIN_SHA)
RUN_AS        ?= ubuntu
ENVIRONMENT   ?= test
workDir       ?= /workdir
TMP_DIR       ?= ./tmp
APP_NAME       = packer-ibmcloud
APP_DIR        = $(workDir)
DockerHub     ?= hub.docker.com
DockerOrg     ?= davide4hire

# The secrets file must set the variables SL_API_KEY and SL_USERNAME.
# These should be valid credentials for the "classic" infrastructure
# These two need to be set in the invoking environment for make
SECRETS_FILE  ?= .env

ANSIBLE_INVENTORY_FILE ?= $(TMP_DIR)/provisioner-hosts
ANSIBLE_HOST_KEY_CHECKING ?= False
OBJC_DISABLE_INITIALIZE_FORK_SAFETY ?= YES
SSH_KEY_NAME           ?= is_rsa
PRIVATEKEY             ?= /home/$(RUN_AS)/.ssh/$(SSH_KEY_NAME)
PUBLICKEY              ?= $(PRIVATEKEY).pub
JSON_FILE              ?= centos.json
NO_ANSIBLE_JSON_FILE    ?= centos-no-ansible.json
PACKER_LOG             ?= 1
PACKER_LOG_DIR	       ?= logs
PACKER_LOG_FILE        ?= packer-build-$(shell date -u +%Y%m%d-%H%M%SZ).log
PACKER_LOG_PATH        ?= $(PACKER_LOG_DIR)/$(PACKER_LOG_FILE)

ContainerName = $(DockerOrg)/$(APP_NAME):$(VERSION)

DOCKER_CMD = docker run --rm --mount type=bind,source=$(PWD),target=$(workDir)

DOCKER_BUILD = --build-arg PACKER_CONTAINER_URL=$(PACKER_CONTAINER_URL) \
	--build-arg PACKER_CONTAINER_VERSION=$(PACKER_CONTAINER_VERSION) \
	--build-arg PLUGIN_GIT_URL=$(PLUGIN_GIT_URL) \
	--build-arg PLUGIN_VERSION=$(PLUGIN_VERSION) \
	--build-arg PLUGIN_SHA=$(PLUGIN_SHA) \
	--build-arg SSH_KEY_NAME=$(SSH_KEY_NAME) \
	--build-arg RUN_AS=$(RUN_AS)

DOCKER_RUN=--env-file=$(SECRETS_FILE) \
	--env ANSIBLE_INVENTORY_FILE=$(ANSIBLE_INVENTORY_FILE) \
	--env ANSIBLE_HOST_KEY_CHECKING=$(ANSIBLE_HOST_KEY_CHECKING) \
	--env OBJC_DISABLE_INITIALIZE_FORK_SAFETY=$(OBJC_DISABLE_INITIALIZE_FORK_SAFETY) \
	--env PRIVATEKEY=$(PRIVATEKEY) \
	--env PUBLICKEY=$(PUBLICKEY) \
	--env PACKER_LOG=$(PACKER_LOG) \
	--env PACKER_LOG_PATH=$(PACKER_LOG_PATH)

##################################################
# Your Project's Targets                         #
##################################################

$(TMP_DIR) $(PACKER_LOG_DIR):
	mkdir -p $@
	chmod a+wx $@

##$(PRIVATEKEY) $(PUBLICKEY): $(TMP_DIR)
##	touch $@

$(SECRETS_FILE):
	@echo "The .env file must contain credintials" && exit 2

foo: $(SECRETS_FILE)
	@echo PWD = $(PWD)
	@echo APP_NAME = $(APP_NAME)
	@echo VERSION = $(VERSION)
	@echo ContainerName = $(ContainerName)
	@echo PACKER_CONTAINER_URL = $(PACKER_CONTAINER_URL)
	@echo PACKER_CONTAINER_VERSION = $(PACKER_CONTAINER_VERSION)
	@echo PLUGIN_GIT_URL = $(PLUGIN_GIT_URL)
	@echo PLUGIN_VERSION = $(PLUGIN_VERSION)
	@echo PLUGIN_SHA = $(PLUGIN_SHA)
	@echo workdir = $(workDir)
	@echo DockerOrg = $(DockerOrg)
	@echo MAKELEVEL = $(MAKELEVEL)


container:
	docker build -t "$(ContainerName)" $(DOCKER_BUILD) .

validate:  $(SECRETS_FILE) $(PACKER_LOG_DIR)
	$(DOCKER_CMD) $(DOCKER_RUN) $(ContainerName) validate $(JSON_FILE)

build: $(SECRETS_FILE) $(PACKER_LOG_DIR)
	$(DOCKER_CMD) $(DOCKER_RUN) $(ContainerName) build $(JSON_FILE)

no-ansible: $(SECRETS_FILE) $(PACKER_LOG_DIR)
	$(DOCKER_CMD) $(DOCKER_RUN) $(ContainerName) build $(NO_ANSIBLE_JSON_FILE)

run:
	$(DOCKER_CMD) $(DOCKER_RUN) -it --entrypoint=bash $(ContainerName) 
