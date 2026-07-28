#!/bin/bash
set -euo pipefail

readonly SERVER_ROOT="${WINDROSE_SERVER_ROOT:-/home/container}"
readonly SERVER_BINARY="${SERVER_ROOT}/R5/Binaries/Linux/WindroseServer-Linux-Shipping"

if [[ ! -f "${SERVER_BINARY}" ]]; then
    echo "Windrose native Linux binary not found: ${SERVER_BINARY}" >&2
    echo "Run the Pterodactyl reinstall process to download the official Docker payload." >&2
    exit 1
fi

chmod u+x "${SERVER_BINARY}"
/usr/local/bin/windrose-configure

cd "${SERVER_ROOT}"
echo "Starting the native Windrose Linux dedicated server..."
exec "${SERVER_BINARY}" R5 -log "$@"
