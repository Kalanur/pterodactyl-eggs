# Upstream contribution plan

## Runtime image

The test image is published as:

`ghcr.io/kalanur/pterodactyl-windrose-native:latest`

It contains no Windrose files. Once validated, submit the Dockerfile and helper
scripts to `Ptero-Eggs/yolks`, probably as a game-specific runtime image. The
maintainers can choose the final path and tag.

## game-eggs changes

Proposed files in `pterodactyl/game-eggs`:

- `windrose/egg-windrose-native-linux.json`
- updated `windrose/README.md`

The existing `egg-windrose.json` Wine egg should remain available because:

- SteamCMD currently distributes only the Windows server payload;
- the official native Docker image may lag behind the game client;
- operators may prefer the established Wine workflow.

The README should describe the native egg as an alternative, not a replacement,
until the publisher distributes Linux files through SteamCMD or guarantees a
stable Docker release process.

## Pull request evidence

Include the following test results in the PR:

- Pterodactyl and Wings versions;
- Unraid version and CPU architecture;
- official Windrose image digest;
- fresh installation result;
- migrated save result;
- startup time Wine vs native Linux;
- graceful stop result;
- reinstall/update result;
- invite-code and direct-connect results;
- any required ports and networking caveats.
