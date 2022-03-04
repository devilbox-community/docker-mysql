#!/usr/bin/env bash
set -e
set -u
set -o pipefail

IMAGE="devilbox/mysql"
TYPE="${1}"
VERSION="${2}"
ARCH="${3}"


if [ "${TYPE}" = "mysql" ]; then
	docker run --rm --platform "${ARCH}" $(tty -s && echo "-it" || echo) "${IMAGE}:${TYPE}-${VERSION}" -V | grep 'MySQL' | grep "${VERSION/./\\.}"
elif [ "${TYPE}" = "mariadb" ]; then
	docker run --rm --platform "${ARCH}" $(tty -s && echo "-it" || echo) "${IMAGE}:${TYPE}-${VERSION}" -V | grep 'MariaDB' | grep "${VERSION/./\\.}"
elif [ "${TYPE}" = "percona" ]; then
	docker run --rm --platform "${ARCH}" $(tty -s && echo "-it" || echo) "${IMAGE}:${TYPE}-${VERSION}" -V | grep 'Percona' | grep "${VERSION/./\\.}"
else
	>&2 echo "[ERROR] Wrong type: ${TYPE}"
	exit 1
fi
