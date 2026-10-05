.PHONY: lint test test-unit test-linux doctor

lint:
	tests/lint.sh

test-unit:
	bats tests/unit

test: lint test-unit

DISTRO ?= ubuntu:24.04
COMPONENTS ?= terminal,apps,wm,claude

test-linux:
	tests/linux/run.sh $(DISTRO) $(COMPONENTS)

doctor:
	tests/verify.sh
