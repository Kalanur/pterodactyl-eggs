# Upstream contribution plan

## Runtime image

The test image is published as:

`ghcr.io/kalanur/pterodactyl-windrose-native:latest`

It is built directly from the official `windroseserver/windroseserver` image and
contains the official Windrose application payload plus the Pterodactyl wrapper.
Only `R5/Saved` and `R5/ServerDescription.json` are persisted in the server
volume. A nightly workflow rebuilds the image when the upstream base changes.

Before proposing this upstream, confirm with the `game-eggs` and `yolks`
maintainers whether they prefer:

- a game-specific image under a Ptero-Eggs registry;
- the external GHCR image maintained here; or
- an installer-based fallback that does not publish a derived game image.

The repository's MIT license covers only the wrapper code, not Windrose files
copied from the official publisher image.

## game-eggs changes

Proposed files in `pterodactyl/game-eggs`:

- `windrose/egg-windrose-native-linux.json`
- updated `windrose/README.md`

The existing `egg-windrose.json` Wine egg should remain available because:

- SteamCMD currently distributes only the Windows server payload;
- the official native Docker image may lag behind the game client;
- operators may prefer the established Wine workflow.

The README should describe the native egg as an alternative, not a replacement,
until the publisher guarantees a stable Docker release process.

## Pull request evidence

Include the following test results in the PR:

- Pterodactyl and Wings versions;
- Unraid version and CPU architecture;
- official Windrose image digest;
- fresh installation result;
- migrated save result;
- startup time Wine vs native Linux;
- graceful stop result;
- image update and rollback result;
- generated-value persistence result;
- invite-code and direct-connect results;
- internal backup and Pterodactyl backup restore results;
- any required ports and networking caveats.
