#######################################
# VARIABLES
#
# Set these at runtime to override the below defaults.
# e.g.:
# `make CMD=/bin/bash debug`
# `make VERSION=debug build`
#######################################

# Uncomment when debugging Makefile
# SHELL = sh -xv

CMD := /bin/bash
DOCKER_IMAGE_FULLNAME := airstack/json-utils


# .PHONY should include all commands
.PHONY: default all init test build clean run repair

################################################################################
# GENERAL COMMANDS
################################################################################

default: build

all:
	@echo all
	make build
	make run

init:
	@echo init
ifeq ($(uname_S),Darwin)
ifneq ($(shell boot2docker status),running)
	@boot2docker up
endif
export DOCKER_HOST=tcp://$(shell boot2docker ip 2>/dev/null):2375
endif

test:
	@echo test
	make CMD="core-test-runner -f /package/json/json-utils/test/*_spec.lua" run

build: init
	@echo build
	@docker build --rm --tag $(DOCKER_IMAGE_FULLNAME) .

clean: init
	@echo "Removing docker image tree for $(DOCKER_IMAGE_FULLNAME) ..."
	docker rmi $(DOCKER_IMAGE_FULLNAME)

run:
	docker run --rm -it $(DOCKER_IMAGE_FULLNAME) $(CMD)



################################################################################
# BOOT2DOCKER CONVENIENCE COMMANDS
################################################################################

repair: init
ifeq ($(uname_S),Darwin)
	@printf "\n\
	=====================\n\
	Repairing boot2docker\n\
	=====================\n\
	"
	@printf "\nTurning off existing boot2docker VMs..."
	@boot2docker poweroff
	@printf "DONE\n"

	@printf "\nRemoving existing boot2docker setup..."
	@boot2docker destroy
	@printf "DONE\n"

	@printf "\nInitializing new boot2docker setup..."
	boot2docker init > /dev/null
	@printf "DONE\n"
endif
