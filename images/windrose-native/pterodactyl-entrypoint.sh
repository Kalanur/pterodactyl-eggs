#!/bin/bash
set -euo pipefail

cd /home/container
mkdir -p /home/container/R5/Saved/.windrose-var-tmp

if [[ -n "${STARTUP:-}" ]]; then
    exec /bin/bash -lc "${STARTUP}"
fi

if [[ "$#" -gt 0 ]]; then
    exec "$@"
fi

exec /usr/local/bin/windrose-start
