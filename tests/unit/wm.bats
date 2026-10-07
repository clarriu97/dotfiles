#!/usr/bin/env bats

setup() {
    REPO="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
    AEROSPACE="$REPO/wm/macos/aerospace/.aerospace.toml"
    KARABINER="$REPO/wm/macos/karabiner/karabiner.json"
}

@test "karabiner.json is generated from the AeroSpace bindings (run: just karabiner, after editing .aerospace.toml)" {
    diff <("$REPO/wm/macos/karabiner/generate.sh") "$KARABINER"
}

@test "Left Option combinations outside the window-manager bindings stay free" {
    run jq -e '[.profiles[].complex_modifications.rules[].manipulators[] | select(.from.key_code == "c" and (.from.modifiers.mandatory | index("shift") | not))] | length == 0' "$KARABINER"
    [ "$status" -eq 0 ]
}

@test "Karabiner only remaps Left Option, never Right Option" {
    run jq -e '[.profiles[].complex_modifications.rules[].manipulators[].from.modifiers.mandatory] | all(.[0] == "left_option" and (index("right_option") | not))' "$KARABINER"
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

@test "Left Option + d reaches Raycast's own hotkey, AeroSpace does not launch it" {
    ! grep -q '^ctrl-alt-d ' "$AEROSPACE"
    run jq -e '[.profiles[0].complex_modifications.rules[].manipulators[] | select(.from.key_code == "d" and .from.modifiers.mandatory == ["left_option"] and .to[0].modifiers == ["left_control", "left_option", "left_shift", "left_command"])] | length == 1' "$KARABINER"
    [ "$status" -eq 0 ]
}
