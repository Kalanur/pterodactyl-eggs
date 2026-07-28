# Windrose Native Linux

A Pterodactyl egg for the official native Linux Windrose dedicated server.

The egg does **not** redistribute Windrose. During installation it downloads
`windroseserver/windroseserver` from Docker Hub and extracts
`/home/ue_user/app` into the Pterodactyl server volume.

The runtime image `ghcr.io/kalanur/pterodactyl-windrose-native:latest` contains
only Debian runtime libraries and the configuration/startup helpers maintained
in this repository.

## Status

Experimental until tested on a real Wings node with a new world, migration from
the Wine egg, invite-code and direct connections, reinstall/update, graceful
shutdown and backup restore. Do not migrate both production servers together.

## Installation

1. Import `egg-windrose-native-linux.json` into Pterodactyl.
2. Create a disposable test server on an amd64 node.
3. Allocate at least 35 GB storage and the RAM recommended by Windrose.
4. For Direct Connect, expose the primary allocation through both TCP and UDP.

The installer uses `skopeo` and `umoci`; it does not require access to the host
Docker socket.

## Updating

Use Pterodactyl's **Reinstall Server** action after the official Windrose image
is updated. The installer preserves:

- `R5/Saved/`
- `R5/ServerDescription.json`
- `.windrose-deployment-id`
- `.windrose-image-digest`

Create a Pterodactyl backup before reinstalling.

## Migration from the Wine egg

1. Create a full backup.
2. Clone the server or copy its files into a disposable test server.
3. Change the test server to this egg and runtime image.
4. Run **Reinstall Server**.
5. Verify world, persistent server ID, invite code, password and connectivity.
6. Compare startup duration and memory use.
7. Migrate production only after repeated successful starts and shutdowns.

## Development

From this directory:

```bash
python3 tools/generate_egg.py
python3 -m unittest discover -s tests -v
bash -n scripts/install.sh
```

Runtime scripts and Dockerfile live in `images/windrose-native/` at repository
root.
