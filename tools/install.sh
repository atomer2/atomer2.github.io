#!/usr/bin/env bash
#
# Install local dependencies for this Jekyll/Chirpy blog.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

help() {
  cat <<'EOF'
Install local dependencies for this blog.

Usage:
  bash tools/install.sh

What this does:
  1. Checks that Ruby is installed
  2. Checks that Bundler is installed
  3. Runs `bundle install` in the repo root

Notes:
  - This script installs project gems locally for the current environment.
  - If Ruby or Bundler is missing, the script prints the next command to run.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  help
  exit 0
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "Ruby is not installed."
  echo "Install it first, then re-run this script."
  echo
  echo "Ubuntu/WSL example:"
  echo "  sudo apt update"
  echo "  sudo apt install ruby-full build-essential zlib1g-dev"
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler is not installed."
  echo "Install it first, then re-run this script."
  echo
  echo "Command:"
  echo "  gem install bundler"
  exit 1
fi

cd "$ROOT_DIR"

echo "Installing gems from Gemfile ..."
bundle config set --local path ~/.vendor/bundle
bundle install

echo
echo "Dependencies installed."
echo "Start the local preview with:"
echo "  bash tools/run.sh"
