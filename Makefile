AIRSTACK_IMAGE_NAME := airstack/json-utils
AIRSTACK_BUILD_TEMPLATES_DIR := $(CURDIR)
AIRSTACK_BUILD_TEMPLATES_DEVELOPMENT := Dockerfile
AIRSTACK_BUILD_TEMPLATES_TEST := $(AIRSTACK_BUILD_DEVLOPMENT)
AIRSTACK_BUILD_TEMPLATES_PRODUCTION := $(AIRSTACK_BUILD_DEVLOPMENT)


################################################################################
# BOOTSTRAP MAKEFILE: DO NOT EDIT BELOW THIS LINE
AIRSTACK_HOME ?= ~/.airstack
ifeq ($(shell test -d $(AIRSTACK_HOME)/package/airstack/bootstrap && echo y),y)
include $(AIRSTACK_HOME)/package/airstack/bootstrap/Makefile
else
.PHONY: init
init:
	curl -s https://raw.githubusercontent.com/airstack/bootstrap/master/install | sh -e
	@$(MAKE) init
.DEFAULT:
	@echo Please run \'make init\' to initialize Airstack
endif
