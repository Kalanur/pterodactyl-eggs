# Kalanur Pterodactyl Eggs

Community-maintained Pterodactyl eggs and supporting runtime images.

## Available eggs

| Game | Variant | Status |
|---|---|---|
| [Windrose](games/windrose/native-linux/) | Native Linux | Experimental / testing |

## Repository layout

- `games/` contains importable eggs, installers, tests and game-specific documentation.
- `images/` contains runtime images required by individual eggs.
- `.github/workflows/` validates eggs and publishes runtime images.

Some game-specific runtime images are built from an official publisher image and
therefore contain upstream application files. The repository's MIT license
applies only to the original wrapper code and documentation in this repository,
not to third-party game files included from an upstream image.

Each egg documents its installation, migration and update procedure in its own directory.
