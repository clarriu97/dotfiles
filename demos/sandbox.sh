#!/usr/bin/env bash
# Builds a throwaway home with this repo's shell config and a small sample
# project, so the README recordings never show a real home, history or paths.
#   demos/sandbox.sh /tmp/dotfiles-demo
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
home="$1"

rm -rf "$home"
mkdir -p "$home/.config/zsh" "$home/projects/weather-app/src" "$home/projects/notes" "$home/Downloads"
mkdir "$home/dotfiles"
tar -C "$REPO" --exclude .git --exclude .env --exclude tests/vm/out --exclude tests/vm/.venv -cf - . |
    tar -C "$home/dotfiles" -xf -
repo="$home/dotfiles"
ln -s "$repo/shell/.zshrc" "$home/.zshrc"
ln -s "$repo/shell/.p10k.zsh" "$home/.p10k.zsh"
case "$(uname -s)" in
    Darwin) ln -s "$repo/shell/zshrc.macos.sh" "$home/.config/zsh/zshrc.macos.sh" ;;
    Linux)  ln -s "$repo/shell/zshrc.linux.sh" "$home/.config/zsh/zshrc.linux.sh" ;;
esac

cd "$home/projects/weather-app"
cat > README.md <<'MD'
# weather-app

Tiny demo project: prints today's forecast.
MD
cat > src/main.py <<'PY'
import json
from urllib.request import urlopen


def forecast(city: str) -> str:
    url = f"https://wttr.in/{city}?format=j1"
    data = json.load(urlopen(url))
    today = data["weather"][0]
    return f"{city}: {today['mintempC']}°C - {today['maxtempC']}°C"


if __name__ == "__main__":
    print(forecast("Madrid"))
PY
printf 'run:\n    python3 src/main.py\n' > justfile
touch src/__init__.py .env.example
export GIT_AUTHOR_NAME=demo GIT_AUTHOR_EMAIL=demo@example.com GIT_COMMITTER_NAME=demo GIT_COMMITTER_EMAIL=demo@example.com
git init -q -b main
git add -A && git commit -qm "feat: first forecast"
git switch -qc feat/units
echo "UNITS = 'metric'" > src/config.py && git add -A && git commit -qm "feat: metric units"
echo "TIMEOUT = 5" >> src/config.py && git commit -qam "fix: request timeout"
git switch -q main
echo "Run it with \`just run\`." >> README.md && git commit -qam "docs: how to run"
git merge -q --no-ff feat/units -m "Merge branch 'feat/units'"
echo "# TODO" > TODO.md

HOME="$home" zoxide add "$home/projects/weather-app" "$home/projects/notes" "$home/Downloads"
