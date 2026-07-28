#!/bin/bash
set -euo pipefail

readonly TARGET_DIRECTORY="/mnt/server"

mkdir -p \
    "${TARGET_DIRECTORY}/R5/Saved/.windrose-var-tmp" \
    "${TARGET_DIRECTORY}/R5"

if [[ -f "${TARGET_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping" ]]; then
    echo "Legacy Windrose application files were detected in the server volume."
    echo "They are ignored because the current runtime image contains the application payload."
    echo "Remove them only after verifying the new image and keeping a backup."
fi

cat <<'MESSAGE'
Windrose persistent storage initialized.
The official native server payload is included in the runtime image and is updated by pulling a newly built image.
R5/Saved and R5/ServerDescription.json remain in the Pterodactyl server volume.
MESSAGE
