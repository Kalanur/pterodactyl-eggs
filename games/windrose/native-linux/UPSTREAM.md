# Upstream contribution plan

## Runtime image

The tested image is published as:

`ghcr.io/kalanur/pterodactyl-windrose-native:latest`

It is built from the publisher-maintained `windroseserver/windroseserver` image
and contains the Windrose Linux application payload plus the community-maintained
Pterodactyl wrapper. Only `R5/Saved` and `R5/ServerDescription.json` are
persisted in the server volume.

A scheduled workflow checks the upstream digest nightly and skips the multi-GB
build when that digest is already published. New images receive `latest`, an
upstream digest tag, the wrapper Git revision, and—when available—the matching
publisher version tag prefixed with `windrose-`.

Before proposing this upstream, confirm with the `game-eggs` and `yolks`
maintainers whether they prefer:

- a game-specific image under a Ptero-Eggs registry;
- the external GHCR image maintained here; or
- an installer-based fallback that does not publish a derived game image.

The repository's MIT license covers only the wrapper code, not Windrose files
copied from the publisher image.

## game-eggs changes

Proposed files in `pterodactyl/game-eggs`:

- existing `windrose/egg-windrose.json` for the SteamCMD/Windows/Wine variant;
- new `windrose/egg-windrose-linux.json` for the publisher-Docker/Linux variant;
- updated `windrose/README.md` comparing both installation and update paths.

The existing Wine egg should remain available because:

- SteamCMD distributes the Windows server payload;
- the publisher's Docker release may follow a different release cadence;
- operators may prefer the established SteamCMD/Wine workflow.

The Linux egg should be presented as an alternative rather than being described
as an official Pterodactyl integration. The publisher supplies the Linux payload;
the Egg and wrapper image remain community maintained.

## Pull request evidence

Include the following verified results in the PR:

- installation and fresh world creation;
- import of an existing world;
- generated-value persistence and explicit world-ID override;
- invite-code/P2P connection;
- direct connection through the public hostname and allocation port;
- periodic internal backups;
- synchronous shutdown backup and RocksDB close;
- persisted gameplay state after restart;
- restore into a newly created server from only `R5/Saved/` and
  `R5/ServerDescription.json`;
- runtime image update without reinstall and without world-state loss;
- amd64 requirement and TCP/UDP allocation caveat;
- upstream shutdown messages observed after the completed engine shutdown.

Still collect exact environment versions and, where possible, comparable startup
timings before opening the PR.
