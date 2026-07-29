# Windrose runtime image contribution

This directory stages the files intended for a future contribution to
`Ptero-Eggs/yolks` as `games/windrose/`.

The image is game-specific and therefore targets:

```text
ghcr.io/ptero-eggs/games:windrose
```

It copies the native Linux dedicated-server payload from the publisher-provided
`windroseserver/windroseserver` image and adds the non-editable startup and
configuration helpers required by the Pterodactyl egg.

## Architecture

The publisher image currently provides an amd64 payload. The corresponding
entry in `.github/workflows/games.yml` must therefore be added to the amd64-only
matrix.

## Persistent paths

Only these server-volume paths are persistent:

- `R5/Saved/`
- `R5/ServerDescription.json`
- `R5/GeneratedServerValues.txt`

The application payload remains inside the runtime image.

## Upstream prerequisites

Before submitting the egg to `Ptero-Eggs/game-eggs`:

1. Submit this runtime image to `Ptero-Eggs/yolks` from a dedicated fork branch.
2. Confirm that redistribution of the publisher-provided payload in the Ptero-Eggs registry is acceptable.
3. After the image is available, point the panel-exported egg at `ghcr.io/ptero-eggs/games:windrose`.
