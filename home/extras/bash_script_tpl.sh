#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# Decent error messages
trap 'echo "[ERR] Exit status $? at line $LINENO from: \`$BASH_COMMAND\`"' ERR

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd -P)

usage() {
	cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
	exit
}

cleanup() {
	trap - SIGINT SIGTERM ERR EXIT
	# script cleanup here
}

setup_colors() {
	if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
		NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
	else
		NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
	fi
}

# Draws a simple box
# ┌─┐╔═╗╭─╮
# │ │║ ║│ │
# └─┘╚═╝╰─╯
# Usage: echo "hallo" | box
#
# Positional parameters:
# ----------------------
# bordercolor : 31:Red, 32:Green, 33:Yellow, 34:Blue, Magenta:35, Cyan:36, White:37
# Title       : Title in top border
# bordertype  : 0=plain, 3=double, 6=rounded
#
# shellcheck disable=all
box() {
	local contents=() max=$#2 T="┌─┐╔═╗╭─╮│││║║║│││└─┘╚═╝╰─╯" C="" R='\033[0m'
	r=${3:-0}
	[[ -n "${1:-}" ]] && C="\033[1;${1}m"
	while IFS= read -r l; do contents+=("$l"); done # Works on Linux/mac/bash/zsh
	r() { printf "$1%.0s" $(seq 0 "$2"); }
	b() { echo "${T:$1:1}"; }
	for line in "${contents[@]}"; do [[ "${#line}" -gt "$max" ]] && max=${#line}; done
	echo -e "$C$(b $3)$(b $(($3 + 1)))${2:-}$(r "$(b $(($3 + 1)))" "$((max - ${#2}))")$(b $(($3 + 2)))$R"
	for line in "${contents[@]}"; do echo -e "$C$(b $(($3 + 9)))$R $(echo "$line" | expand -t 1)$(r " " $((max - ${#line})))$C$(b $(($3 + 9)))$R"; done
	echo -e "$C$(b $(($3 + 18)))$(r "${T:(($3 + 19)):1}" "$((max + 1))")$(b $(($3 + 20)))$R"
}

msg() {
	echo >&2 -e "${1-}"
}

die() {
	local msg=$1
	local code=${2-1} # default exit status 1
	msg "$msg"
	exit "$code"
}

ead() {
	echo "$*"
	"$@"
}

requireCommand() {
	for c in "$@"; do
		command -v "$c" &>/dev/null || fail "'$c' command not found, please install it"
	done
}

parse_params() {
	# default values of variables set from params
	flag=0
	param=''

	while :; do
		case "${1-}" in
		-h | --help) usage ;;
		-v | --verbose) set -x ;;
		--no-color) NO_COLOR=1 ;;
		-f | --flag) flag=1 ;; # example flag
		-p | --param)          # example named parameter
			param="${2-}"
			shift
			;;
		-?*) die "Unknown option: $1" ;;
		*) break ;;
		esac
		shift
	done

	args=("$@")

	# check required params and arguments
	[[ -z "${param-}" ]] && die "Missing required parameter: param"
	[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

	return 0
}

parse_params "$@"
setup_colors
