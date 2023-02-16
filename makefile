PROJECT_DIR=${shell cd .; pwd}
PROJECT_NAME=${shell basename ${PROJECT_DIR}}
DOCKER_RUN=docker container run \
				--rm \
				--interactive \
				--tty \
				--mount=type=bind,source=${PROJECT_DIR},destination=/${PROJECT_NAME} \
				--workdir=/${PROJECT_NAME} ${PROJECT_NAME}

.PHONY: all
all:	docker-image-build \
		test

.PHONY: help
help:
	@echo "Targets:"
	@sed -nr 's/^.PHONY:(.*)/\1/p' ${MAKEFILE_LIST}		

.PHONY: docker-image-build
docker-image-build:
	@docker image build --tag=${PROJECT_NAME} ${PROJECT_DIR}

.PHONY: clean
clean:
	@${DOCKER_RUN} swift package clean

.PHONY: shell
shell:
	@${DOCKER_RUN} bash

.PHONY: test
test:	test-swift \
		test-turnt

.PHONY: test-swift
test-swift:
	@${DOCKER_RUN} swift test

.PHONY: test-turnt
test-turnt:
	@${DOCKER_RUN} bash ./run_turnt_tests.sh

.PHONY: driver
driver:
	@${DOCKER_RUN} swift run driver

.PHONY: format
format:
	@swift-format format --in-place --recursive ./Sources ./Tests Package.swift
