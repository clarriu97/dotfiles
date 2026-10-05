#!/usr/bin/env bash
# Harness self-test: the VM boots to a usable desktop and the keyboard
# produces Spanish ISO characters from physical keys.

desktop_is_usable "boot"

step "Keyboard (Spanish ISO, no remapping installed)"
typed="$(capture_keys /tmp/smoke-keys.txt "type hola" "key space" "combo rmeta+2" "combo lmeta+2" "key ;")"
echo "typed: $typed"
if [[ "$typed" == "hola @@ñ" ]]; then pass "physical keys -> 'hola @@ñ'"; else fail "physical keys -> 'hola @@ñ' (got '$typed')"; fi
