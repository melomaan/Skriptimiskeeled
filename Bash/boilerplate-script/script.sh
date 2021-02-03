#!/usr/bin/env bash
# Üllar Seerme

set -Eeuo pipefail
# Remove 'EXIT' as a signal if you don't to clean up after normal exit as well
trap cleanup SIGINT SIGTERM ERR EXIT

readonly SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
readonly SCRIPT_VER='0.1.0'

function usage() {
  cat << EOF
Usage: ${SCRIPT_NAME} [-h | --help] [-v | --verbose] [-V | --version] [--no-color]
                 --param-one <arg> [-f | --flag-one]

Example script for starting a new project.

Available options:

-h, --help             Print this help and exit
-v, --verbose          Print script debug info
-V, --version          Print version number and exit
--no-color             Disable colored messages

-p, --param-one        Required parameter with both short and long variant.

-f, --flag-one         Flag with both short and long variant.
                       Can be set from the 'PROJ_FLAG_ONE' environment variable.

Example: ${SCRIPT_NAME} --param-one "some value"

Example: ${SCRIPT_NAME} --flag-one

EOF
  exit
}

function setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

function msg() {
  echo >&2 -e "${1-} ${NOFORMAT-}"
}

function die() {
  local msg=$1
  local code=${2-1}
  msg "$msg"
  exit "$code"
}

function cleanup() {
  # Disallow Ctrl+C while function is being executed by specifying null string
  # Learn more by reading help page: help trap
  # Revert by replacing null string with a single hyphen
  trap "" SIGINT SIGTERM ERR EXIT

  set +u
  if [[ "${#created_resources[@]}" -ne 0 ]]; then
    msg 'Caught a signal. Starting clean-up procedure'
    # Adding quotes around arrays will cause
    # command to improperly list array items
    #
    # shellcheck disable=SC2086
    rm -rf ${created_resources[*]}
    die 'Finished clean-up procedure. Exiting'
  else
    die 'Nothing to clean up. Exiting'
  fi
  set -u
}

function parse_params() {
  param_one=''
  flag_one=${PROJ_FLAG_ONE:-false}

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose)
      set -x
      # Automatically pass shell option to other scripts that may get called
      export SHELLOPTS
      ;;
    -V | --version) echo "$SCRIPT_VER" && exit ;;
    --no-color) export NO_COLOR=1 ;;
    -p | --param-one)
      param_one="${2-}"
      shift
      ;;
    -f | --flag-one)
      flag_one=true
      ;;
    -?*) die "Unknown option: ${1}" ;;
    *) break ;;
    esac
    shift
  done

  [[ -z "${param_one-}" ]] && die "Missing required parameter: 'param-one'"

  return 0
}

parse_params "$@"
setup_colors

msg "${GREEN}Read parameters:"
msg "- param-one: '${param_one}'"
msg "- flag-one: '${flag_one}'"

tmp=$(mktemp)
created_resources+=("$tmp")
