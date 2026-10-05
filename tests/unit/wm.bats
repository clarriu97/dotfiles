#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    AEROSPACE="$REPO/wm/macos/aerospace/.aerospace.toml"
    KARABINER="$REPO/wm/macos/karabiner/karabiner.json"
}

aerospace_keys() {
    sed -nE 's/^ctrl-alt-(shift-|cmd-)?([a-z0-9]+) =.*/\2/p' "$AEROSPACE" |
        sed -E -e 's/^enter$/return_or_enter/' -e 's/^space$/spacebar/' \
            -e 's/^(left|right|up|down)$/\1_arrow/' | sort -u
}

karabiner_keys() {
    jq -r '.profiles[] | select(.name == "Dotfiles") | .complex_modifications.rules[].manipulators[].from.key_code' "$KARABINER" | sort -u
}

@test "every AeroSpace binding is reachable through the Karabiner layer, and nothing else is remapped" {
    diff <(aerospace_keys) <(karabiner_keys)
}

@test "Karabiner only remaps Left Option, never Right Option" {
    run jq -e '[.profiles[].complex_modifications.rules[].manipulators[].from.modifiers.mandatory] | flatten | unique == ["left_option"]' "$KARABINER"
    [ "$status" -eq 0 ]
}

@test "Karabiner has a selected Dotfiles profile and an empty Plain profile for dotfiles rescue" {
    run jq -e '(.profiles | map(select(.name == "Dotfiles" and .selected)) | length == 1) and (.profiles | map(select(.name == "Plain" and (.complex_modifications.rules | length == 0))) | length == 1)' "$KARABINER"
    [ "$status" -eq 0 ]
}

@test "Karabiner keyboard type is ISO (Spanish keyboard: no < / º swap)" {
    run jq -e 'all(.profiles[]; .virtual_hid_keyboard.keyboard_type_v2 == "iso")' "$KARABINER"
    [ "$status" -eq 0 ]
}

@test "AeroSpace uses no plain alt bindings (they would steal Option symbols)" {
    run grep -nE '^(alt|cmd|shift)-' "$AEROSPACE"
    [ "$status" -ne 0 ]
}

@test "the rescue config binds nothing, does not start at login and disables itself" {
    rescue="$REPO/wm/macos/aerospace/rescue.toml"
    grep -qx 'start-at-login = false' "$rescue"
    grep -qx "after-startup-command = \['enable off'\]" "$rescue"
    [ -z "$(sed -n '/^\[mode.main.binding\]/,$p' "$rescue" | grep -E '^[a-z].*=')" ]
}

@test "focus keys match Ubuntu i3 (j k l ñ)" {
    for pair in "j:left" "k:down" "l:up" "semicolon:right"; do
        grep -q "^ctrl-alt-${pair%%:*} = 'focus ${pair##*:}'" "$AEROSPACE"
    done
    grep -q '^bindsym $mod+j focus left' "$REPO/wm/linux/i3/config"
    grep -q '^bindsym $mod+ntilde focus right' "$REPO/wm/linux/i3/config"
}
