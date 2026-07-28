# Windrose Native Linux

A Pterodactyl egg for the official native Linux Windrose dedicated server.

The runtime image is built from `windroseserver/windroseserver:latest` and
contains the official application payload. Only persistent data is stored in the
Pterodactyl server volume:

- `R5/Saved/`
- `R5/ServerDescription.json`
- `R5/GeneratedServerValues.txt`

## Status

Successfully tested on a real amd64 Wings node with installation, fresh world
creation, generated invite code, backend registration and client connection.
Migration, direct connection, graceful shutdown/restart, image update and backup
restore still need repeated testing before both production servers are migrated.

## Installation

1. Import `egg-windrose-native-linux.json` into Pterodactyl.
2. Create a server on an amd64 node.
3. For Direct Connect, expose the primary allocation through both TCP and UDP.

The installation script only initializes persistent directories. Windrose
application files are supplied by the runtime image and are not copied into the
server volume.

## Generated invite code and world ID

Leave `INVITE_CODE` and `WORLD_ISLAND_ID` empty for a fresh server. Windrose
creates them and writes them to `R5/ServerDescription.json`. On later starts the
configuration helper preserves those generated values.

A non-empty startup variable is treated as an explicit override. This is useful
when importing an existing world and prevents a generated value from replacing
the requested world or invite code.

Pterodactyl does not natively reverse-sync generated file values into its Panel
database. The runtime therefore prints the effective values to the console and
writes them to:

```text
R5/GeneratedServerValues.txt
```

No Panel API token is required or stored in the game container.

## Automated application updates

A scheduled GitHub Actions workflow checks the official Windrose image every
night and rebuilds:

```text
ghcr.io/kalanur/pterodactyl-windrose-native:latest
```

Wings pulls that image when the server container is recreated. Therefore a
normal server restart after the new image has been published updates the
Windrose application while reusing the existing save and server description.
No Pterodactyl reinstall is required for normal game updates.

Immutable tags are also published as `upstream-<digest-prefix>` and by Git commit
SHA to make image rollback possible. Always create a save backup before applying
a new Windrose version because the game may migrate its data format.

## Runtime backup path

Windrose writes temporary internal world backups below `/var/tmp/R5`. Wings
normally runs game containers with a read-only root filesystem, so the image
maps that path to:

```text
/home/container/R5/Saved/.windrose-var-tmp
```

## Migration from the Wine or first native prototype egg

1. Create a full backup.
2. Clone the server or copy its files into a disposable test server.
3. Change the test server to this egg and runtime image.
4. Leave generated variables empty unless intentionally importing specific values.
5. Start and verify world, persistent server ID, invite code, password and connectivity.
6. Remove legacy application files from the server volume only after successful testing.
7. Migrate production one server at a time.

The new runtime ignores old application files in `/home/container`; they only
consume disk space until manually removed.

## Development

From this directory:

```bash
python3 tools/generate_egg.py
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh
```

Runtime scripts and Dockerfile live in `images/windrose-native/` at repository
root.
