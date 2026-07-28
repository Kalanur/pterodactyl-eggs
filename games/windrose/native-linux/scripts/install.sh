#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

readonly IMAGE_REPOSITORY="${WINDROSE_IMAGE_REPOSITORY:-windroseserver/windroseserver}"
readonly IMAGE_TAG="${WINDROSE_IMAGE_TAG:-latest}"
readonly IMAGE_REFERENCE="docker.io/${IMAGE_REPOSITORY}:${IMAGE_TAG}"
readonly OCI_DIRECTORY="/tmp/windrose-oci"
readonly ROOTFS_DIRECTORY="/tmp/windrose-rootfs"
readonly SOURCE_DIRECTORY="${ROOTFS_DIRECTORY}/rootfs/home/ue_user/app"
readonly TARGET_DIRECTORY="/mnt/server"

cleanup() {
    rm -rf "${OCI_DIRECTORY}" "${ROOTFS_DIRECTORY}"
}
trap cleanup EXIT

echo "Installing tools required to extract the official Windrose Docker image..."
apt-get update
apt-get install --yes --no-install-recommends \
    binutils \
    ca-certificates \
    rsync \
    skopeo \
    umoci

cleanup
mkdir -p "${OCI_DIRECTORY}" "${TARGET_DIRECTORY}"

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

readonly SERVER_BINARY="${SOURCE_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping"
if [[ ! -f "${SERVER_BINARY}" ]]; then
    echo "The official image does not contain the native Linux Windrose binary." >&2
    exit 1
fi

mkdir -p "${TARGET_DIRECTORY}/R5/Saved"

echo "Synchronizing server files while preserving saves and server identity..."
rsync --archive --delete \
    --exclude='R5/Saved/' \
    --exclude='R5/ServerDescription.json' \
    --exclude='.windrose-deployment-id' \
    --exclude='.windrose-image-digest' \
    "${SOURCE_DIRECTORY}/" \
    "${TARGET_DIRECTORY}/"

chmod u+x "${TARGET_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping"

DEPLOYMENT_ID="$({ strings "${TARGET_DIRECTORY}/R5/Binaries/Linux/WindroseServer-Linux-Shipping" || true; } \
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

echo "Windrose native Linux installation completed."
