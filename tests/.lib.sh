#!/usr/bin/env bash

set -e
set -u
set -o pipefail


###
### Run
###
function run() {
	local cmd="${1}"
	local to_stdout=0

	# Output to stdout instead?
	if [ "${#}" -eq "2" ]; then
		to_stdout="${2}"
	fi

	local red="\033[0;31m"
	local green="\033[0;32m"
	local yellow="\033[0;33m"
	local reset="\033[0m"

	if [ "${to_stdout}" -eq "0" ]; then
		printf "${yellow}[%s] ${red}%s \$ ${green}${cmd}${reset}\n" "$(hostname)" "$(whoami)" >&2
	else
		printf "${yellow}[%s] ${red}%s \$ ${green}${cmd}${reset}\n" "$(hostname)" "$(whoami)"
	fi

	if sh -c "${cmd}"; then
		if [ "${to_stdout}" -eq "0" ]; then
			printf "${green}[%s]${reset}\n" "OK" >&2
		else
			printf "${green}[%s]${reset}\n" "OK"
		fi
		return 0
	else
		if [ "${to_stdout}" -eq "0" ]; then
			printf "${red}[%s]${reset}\n" "NO" >&2
		else
			printf "${red}[%s]${reset}\n" "NO"
		fi
		return 1
	fi
}


###
### Run (must fail in order to succeed)
###
function run_fail() {
	local cmd="${1}"
	local to_stdout=0

	# Output to stdout instead?
	if [ "${#}" -eq "2" ]; then
		to_stdout="${2}"
	fi

	local red="\033[0;31m"
	local green="\033[0;32m"
	local yellow="\033[0;33m"
	local reset="\033[0m"

	if [ "${to_stdout}" -eq "0" ]; then
		printf "${yellow}[%s] ${red}%s \$ ${yellow}[NOT] ${green}${cmd}${reset}\n" "$(hostname)" "$(whoami)" >&2
	else
		printf "${yellow}[%s] ${red}%s \$ ${yellow}[NOT] ${green}${cmd}${reset}\n" "$(hostname)" "$(whoami)"
	fi

	if ! sh -c "${cmd}"; then
		if [ "${to_stdout}" -eq "0" ]; then
			printf "${green}[%s]${reset}\n" "OK" >&2
		else
			printf "${green}[%s]${reset}\n" "OK"
		fi
		return 0
	else
		if [ "${to_stdout}" -eq "0" ]; then
			printf "${red}[%s]${reset}\n" "NO" >&2
		else
			printf "${red}[%s]${reset}\n" "NO"
		fi
		return 1
	fi
}

###
### Wait until containers are gone ('docker run --rm' removes them asynchronously),
### so the next test can reuse their names. Force-remove leftovers after 30 seconds, give up after 60.
###
function wait_removed() {
	local name
	local i
	for name in "${@}"; do
		i=0
		while docker container inspect "${name}" >/dev/null 2>&1; do
			i=$(( i + 1 ))
			if [ "${i}" -ge "60" ]; then
				>&2 echo "[ERROR] Container ${name} is still present"
				return 1
			fi
			if [ "${i}" -ge "30" ]; then
				docker rm -f "${name}" >/dev/null 2>&1 || true
			fi
			sleep 1
		done
	done
}

###
### Compare version
###
function ver() {
  IFS='.' read -r major minor patch <<< "${1}"
  printf "%02d%02d%02d" "$major" "$minor" "$patch"
}
