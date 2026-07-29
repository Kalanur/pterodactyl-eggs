# Windrose

Embark on a PvE survival adventure in the Age of Piracy. Fight on land and sea, solo or with friends. Build, craft and explore a vast open world filled with dark secrets.

## Available eggs

- `egg-windrose.json` installs the Windows dedicated server through SteamCMD and runs it with Wine.
- `egg-windrose-linux.json` runs the native Linux server payload distributed through the publisher's Docker image using `ghcr.io/ptero-eggs/games:windrose`.

The Linux egg stores only persistent server data in the Pterodactyl volume. Application updates are delivered through rebuilt container images and do not require a Pterodactyl reinstall.

## Warning

When running in a virtual machine, expose the host CPU feature set through host or passthrough CPU mode. Missing CPU features can cause illegal-instruction crashes.

The Linux runtime is currently available for `linux/amd64` only because the publisher image does not provide an arm64 payload.

## Server requirements

| Players | RAM | Storage |
|---|---:|---:|
| 2 | 8 GB | 32 GB SSD |
| 4 | 12 GB | 32 GB SSD |
| 10 | 16 GB | 32 GB SSD |

## Connecting to the server

Players can connect by either:

- Direct Connect using the server's allocated hostname or IP and port. The allocation must be reachable through both TCP and UDP.
- Invite Code/P2P mode using the effective invite code and optional password.

Invite Code and World Island ID may be left empty. Windrose will generate or preserve them in `R5/ServerDescription.json`. The Linux runtime also prints the effective values and writes them to `R5/GeneratedServerValues.txt`.

Invite Code/P2P mode and Direct Connect are alternative connection modes. The invite code is not used while Direct Connect is enabled.

## Persistent files for the Linux egg

The relevant persistent data is:

```text
R5/Saved/
R5/ServerDescription.json
R5/GeneratedServerValues.txt
```

For migration or disaster recovery, restore at least `R5/Saved/` and `R5/ServerDescription.json` before starting the replacement server.

## Updates and backups

The Linux application payload is included in the runtime image. A newly published image is applied when Wings recreates the server container; the saved world and server configuration remain in the server volume.

Create a backup before applying a new Windrose version because game updates may migrate save data. Windrose's internal backup path is redirected into the persistent server volume.
