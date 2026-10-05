#!/usr/bin/env bash
# Generates karabiner.json from the AeroSpace bindings, so Karabiner remaps
# exactly the Left Option combinations AeroSpace uses and nothing else:
#   ctrl-alt-KEY        <- Left Option + KEY
#   ctrl-alt-shift-KEY  <- Left Option + Shift + KEY
#   ctrl-alt-cmd-KEY    <- Left Option + Cmd + KEY
#
#   wm/macos/karabiner/generate.sh > wm/macos/karabiner/karabiner.json
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
AEROSPACE="$DIR/../aerospace/.aerospace.toml"

sed -n '/^\[mode\.main\.binding\]/,/^\[/p' "$AEROSPACE" |
    sed -nE 's/^ctrl-alt-((shift|cmd)-)?([a-z0-9]+) =.*/\2 \3/p' |
    jq -R -n '
def key_code: {enter: "return_or_enter", space: "spacebar", left: "left_arrow", right: "right_arrow", up: "up_arrow", down: "down_arrow"}[.] // .;
def extra: {"": [], shift: ["shift"], cmd: ["command"]}[.];
def extra_out: {"": [], shift: ["left_shift"], cmd: ["left_command"]}[.];
[inputs | split(" ") | {mod: .[0], key: (.[1] | key_code)}] as $bindings
| {
    description: "Left Option + window-manager keys -> Ctrl+Option (AeroSpace). Generated from .aerospace.toml by generate.sh; Right Option and every other Left Option combination are untouched.",
    manipulators: [ $bindings[] | {
      type: "basic",
      from: { key_code: .key, modifiers: { mandatory: (["left_option"] + (.mod | extra)) } },
      to: [ { key_code: .key, modifiers: (["left_control", "left_option"] + (.mod | extra_out)) } ]
    } ]
  } as $rule
| def profile($name; $selected; $rules): {
    name: $name,
    selected: $selected,
    virtual_hid_keyboard: { keyboard_type_v2: "iso" },
    complex_modifications: { rules: $rules }
  };
{
  global: { check_for_updates_on_startup: true, show_in_menu_bar: true, show_profile_name_in_menu_bar: false },
  profiles: [ profile("Dotfiles"; true; [$rule]), profile("Plain"; false; []) ]
}'
