.PHONY: lint test test-unit test-linux

lint:
	tests/lint.sh

test-unit:
	bats tests/unit

test: lint test-unit
