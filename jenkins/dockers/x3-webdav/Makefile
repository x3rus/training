#
#
# Author : Thomas Boutry <thomas.boutry@x3rus.com>
# Licence : GPLv3+
# Description : Compilation / creation du conteneur x3-webdav
# #############################################################

########
# VARS #

DIR-VALIDATION = validations/integration-testing
DCK-COMPOSE-OPT = "--force-rm"

###########
# TARGETS #

all: unittest build push

help:
	@echo Targets:
	@echo -e " all\t\tBuild, unittest and push ."
	@echo -e " unittest\tBuild contener with temporary name and perform integration script."
	@echo -e " build\tDo unittest and build real conteneur."
	@echo -e " push\t\tpush to the docker private docker registrie or public."

unittest: build-and-test cleanup-test

build-and-test:
	cd $(DIR-VALIDATION) && docker-compose build $(DCK-COMPOSE-OPT) && docker-compose up -d x3-webdav 
	cd $(DIR-VALIDATION) && docker-compose run x3-webdav-cli

cleanup-test:
	cd $(DIR-VALIDATION) && docker-compose stop x3-webdav && docker-compose rm --force
