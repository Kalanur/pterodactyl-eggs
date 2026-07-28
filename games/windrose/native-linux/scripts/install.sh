#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

readonly IMAGE_REPOSITORY="${WINDROSE_IMAGE_REPOSITORY:-windroseserver/windroseserver}"
readonly IMAGE_TAG="${WINDROSE_IMAGE_TAG:-latest}"
readonly IMAGE_REFERENCE="docker.io/${IMAGE_REPOSITORY}:${IMAGE_TAG}"
readonly TARGET_DIRECTORY="/mnt/server"
readonly STAGING_DIRECTORY="${TARGET_DIRECTORY}/.windrose-install"
readonly OCI_DIRECTORY="${STAGING_DIRECTORY}/oci"
readonly ROOTFS_DIRECTORY="${STAGING_DIRECTORY}/rootfs"
readonly SOURCE_DIRECTORY="${ROOTFS_DIRECTORY}/rootfs/home/ue_user/app"
readonly PERSIST_DIRECTORY="${STAGING_DIRECTORY}/persistent"

COMMIT_STARTED=0

cleanup() {
    local exit_code=$?

    if [[ ${exit_code} -eq 0 || ${COMMIT_STARTED} -eq 0 ]]; then
        rm -rf "${STAGING_DIRECTORY}"
    else
        echo "Installation failed while replacing server files." >&2
        echo "Recovery data was retained in ${PERSIST_DIRECTORY}." >&2
    fi

    trap - EXIT
    exit "${exit_code}"
}
trap cleanup EXIT

echo "Installing tools required to extract the official Windrose Docker image..."
apt-get update
apt-get install --yes --no-install-recommends \
    binutils \
    ca-certificates \
    skopeo \
    umoci
rm -rf /var/lib/apt/lists/*

mkdir -p "${TARGET_DIRECTORY}"

if [[ -e "${PERSIST_DIRECTORY}/Saved" || -e "${PERSIST_DIRECTORY}/ServerDescription.json" ]]; then
    echo "A previous interrupted installation left recovery data in ${PERSIST_DIRECTORY}." >&2
    echo "Restore or remove that directory before reinstalling again." >&2
    exit 1
fi

rm -rf "${STAGING_DIRECTORY}"
mkdir -p "${OCI_DIRECTORY}"

echo "Using the Pterodactyl server volume for installation staging:"
df -h "${TARGET_DIRECTORY}" || true

echo "Downloading official Windrose image: ${IMAGE_REFERENCE}"
skopeo copy \
    --retry-times 3 \
    --override-os linux \
    --override-arch amd64 \
    "docker://${IMAGE_REFERENCE}" \
    "oci:${OCI_DIRECTORY}:windrose"

echo "Unpacking official Windrose image..."
umoci unpack --rootless --image "${OCI_DIRECTORY}:windrose" "${ROOTFS_DIRECTORY}"
rm -rf "${OCI_DIRECTORY}"

if [[ ! -d "${SOURCE_DIRECTORY}" ]]; then
    echo "Expected application path is missing from the official image: ${SOURCE_DIRECTORY}" >&2
    exit 1
fi

readonly SOURCE_SERVER_BINARY="${SOURCE_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping"
if [[ ! -f "${SOURCE_SERVER_BINARY}" ]]; then
    echo "The official image does not contain the native Linux Windrose binary." >&2
    exit 1
fi

echo "Official payload unpacked successfully. Replacing application files..."
mkdir -p "${PERSIST_DIRECTORY}"
COMMIT_STARTED=1

if [[ -d "${TARGET_DIRECTORY}/R5/Saved" ]]; then
    mv "${TARGET_DIRECTORY}/R5/Saved" "${PERSIST_DIRECTORY}/Saved"
fi

if [[ -e "${TARGET_DIRECTORY}/R5/ServerDescription.json" || -L "${TARGET_DIRECTORY}/R5/ServerDescription.json" ]]; then
    mv "${TARGET_DIRECTORY}/R5/ServerDescription.json" "${PERSIST_DIRECTORY}/ServerDescription.json"
fi

find "${TARGET_DIRECTORY}" \
    -mindepth 1 \
    -maxdepth 1 \
    ! -name '.windrose-install' \
    -exec rm -rf -- {} +

shopt -s dotglob nullglob
SOURCE_ENTRIES=("${SOURCE_DIRECTORY}"/*)
if (( ${#SOURCE_ENTRIES[@]} == 0 )); then
    echo "The extracted Windrose application directory is empty." >&2
    exit 1
fi
mv "${SOURCE_ENTRIES[@]}" "${TARGET_DIRECTORY}/"
shopt -u dotglob nullglob

mkdir -p "${TARGET_DIRECTORY}/R5"

if [[ -d "${PERSIST_DIRECTORY}/Saved" ]]; then
    rm -rf "${TARGET_DIRECTORY}/R5/Saved"
    mv "${PERSIST_DIRECTORY}/Saved" "${TARGET_DIRECTORY}/R5/Saved"
else
    mkdir -p "${TARGET_DIRECTORY}/R5/Saved"
fi

if [[ -e "${PERSIST_DIRECTORY}/ServerDescription.json" || -L "${PERSIST_DIRECTORY}/ServerDescription.json" ]]; then
    rm -f "${TARGET_DIRECTORY}/R5/ServerDescription.json"
    mv "${PERSIST_DIRECTORY}/ServerDescription.json" "${TARGET_DIRECTORY}/R5/ServerDescription.json"
fi

readonly SERVER_BINARY="${TARGET_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping"
chmod u+x "${SERVER_BINARY}"

DEPLOYMENT_ID="$({ strings "${SERVER_BINARY}" || true; } \
    | grep -Eo '0\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9A-Fa-f]{8}' \
    | sort -V \
    | tail -n 1 || true)"
if [[ -n "${DEPLOYMENT_ID}" ]]; then
    printf '%s\n' "${DEPLOYMENT_ID}" > "${TARGET_DIRECTORY}/.windrose-deployment-id"
    echo "Detected Windrose deployment: ${DEPLOYMENT_ID}"
else
    echo "Deployment ID could not be detected; the server will populate it when supported."
fi

IMAGE_DIGEST="$(skopeo inspect --format '{{.Digest}}' "docker://${IMAGE_REFERENCE}" || true)"
if [[ -n "${IMAGE_DIGEST}" ]]; then
    printf '%s\n' "${IMAGE_DIGEST}" > "${TARGET_DIRECTORY}/.windrose-image-digest"
    echo "Installed official image digest: ${IMAGE_DIGEST}"
fi

COMMIT_STARTED=0
echo "Windrose native Linux installation completed."
