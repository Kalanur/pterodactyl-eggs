# Windrose - Linux

A Pterodactyl egg for the Linux Windrose dedicated server payload distributed
through the publisher's Docker image.

The community-maintained runtime image is built from
`windroseserver/windroseserver:latest`. Only persistent data is stored in the
Pterodactyl server volume:

- `R5/Saved/`
- `R5/ServerDescription.json`
- `R5/GeneratedServerValues.txt`

## Status

Successfully tested on a real amd64 Wings node with:

- fresh installation and world creation;
- imported existing world;
- generated and preserved invite code and world ID;
- invite-code/P2P connection;
- direct connection through the primary allocation over TCP and UDP;
- periodic internal world backups;
- synchronous backup and clean RocksDB close during shutdown;
- persisted gameplay state after stop and restart;
- restore into a newly created Pterodactyl server using only `R5/Saved/` and
  `R5/ServerDescription.json`;
- runtime image update without reinstall while preserving the world state.

## Installation

1. Import `egg-windrose-linux.json` into Pterodactyl.
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

A scheduled GitHub Actions workflow checks the publisher's Windrose image every
night. A new runtime image is built only when the upstream digest changes.
Repository changes and manually started workflow runs always build.

The default image is:

```text
ghcr.io/kalanur/pterodactyl-windrose-native:latest
```

Wings pulls that image when the server container is recreated. Therefore a
normal server restart after a new image has been published updates the Windrose
application while reusing the existing save and server description. No
Pterodactyl reinstall is required for normal game updates.

The workflow publishes these tags:

- `latest` for normal automatic updates;
- `windrose-<publisher-version>` when a non-latest Docker Hub tag points to the
  same upstream digest;
- `upstream-<digest-prefix>` for exact upstream payload identification;
- the repository Git commit SHA for exact wrapper identification.

Always create a save backup before applying a new Windrose version because the
game may migrate its data format.

## Runtime backup path

Windrose writes temporary internal world backups below `/var/tmp/R5`. Wings
normally runs game containers with a read-only root filesystem, so the image
maps that path to:

```text
/home/container/R5/Saved/.windrose-var-tmp
```

## Migration from the Wine egg or an earlier prototype

1. Create a full backup.
2. Create a disposable server using this egg.
3. Copy `R5/Saved/` and `R5/ServerDescription.json` from the source server.
4. Leave generated variables empty unless intentionally overriding specific values.
5. Start and verify world, persistent server ID, invite code, password and connectivity.
6. Remove legacy application files from the old server volume only after successful testing.

The runtime ignores old application files in `/home/container`; they only
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
