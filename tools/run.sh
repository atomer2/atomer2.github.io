#!/usr/bin/env bash
#
# Run the local Jekyll preview server

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

prod=false
use_livereload=false
host="0.0.0.0"
port="4000"
livereload_port="35729"

help() {
  echo "Usage:"
  echo
  echo "   bash tools/run.sh [options]"
  echo
  echo "Options:"
  echo "     -H, --host [HOST]    Host to bind to. Default: 0.0.0.0"
  echo "     -P, --port [PORT]    Port for the local site server."
  echo "     -l, --livereload     Enable browser auto-refresh."
  echo "         --lr-port [PORT] Port for the LiveReload server."
  echo "     -p, --production     Run Jekyll in 'production' mode."
  echo "     -h, --help           Print this help information."
}

if ! command -v ruby >/dev/null 2>&1; then
  echo "Ruby is not installed."
  echo "Install Ruby first, then run: bash tools/install.sh"
  exit 1
fi

if ! command -v bundle >/dev/null 2>&1; then
  echo "Bundler is not installed."
  echo "Install Bundler first, then run: bash tools/install.sh"
  exit 1
fi

cd "$ROOT_DIR"

if ! bundle check >/dev/null 2>&1; then
  echo "Project gems do not appear to be installed yet."
  echo "Run: bash tools/install.sh"
  exit 1
fi

while (($#)); do
  opt="$1"
  case $opt in
  -H | --host)
    host="$2"
    shift 2
    ;;
  -P | --port)
    port="$2"
    shift 2
    ;;
  -l | --livereload)
    use_livereload=true
    shift
    ;;
  --lr-port)
    livereload_port="$2"
    shift 2
    ;;
  -p | --production)
    prod=true
    shift
    ;;
  -h | --help)
    help
    exit 0
    ;;
  *)
    echo -e "> Unknown option: '$opt'\n"
    help
    exit 1
    ;;
  esac
done

cmd=(bundle exec jekyll s -H "$host" -P "$port")

if $use_livereload; then
  cmd+=(-l --livereload-port "$livereload_port")
fi

if $prod; then
  export JEKYLL_ENV=production
fi

if [ -e /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
  cmd+=(--force_polling)
fi

printf "\n> "
printf "%q " "${cmd[@]}"
printf "\n\n"

exec "${cmd[@]}"
