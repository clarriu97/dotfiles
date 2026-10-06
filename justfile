# List the recipes
default:
    @just --list

# Static checks: shellcheck, zsh syntax, JSON, TOML, Claude settings schema, i3 config
lint:
    tests/lint.sh

# Unit tests (bats)
test-unit:
    bats tests/unit

# Lint and unit tests
test: lint test-unit

# Unattended install + doctor in a fresh Linux container
test-linux distro="ubuntu:24.04" components="terminal,apps,wm,claude":
    tests/linux/run.sh {{distro}} {{components}}

# macOS VM scenario: smoke, fresh, existing (from base) or golden (from golden)
test-vm scenario source="base":
    tests/vm/vm.sh run {{scenario}} {{source}}

# Health check of the installed setup
doctor *args:
    tests/verify.sh {{args}}

# Regenerate karabiner.json from the AeroSpace bindings
karabiner:
    wm/macos/karabiner/generate.sh > wm/macos/karabiner/karabiner.json
