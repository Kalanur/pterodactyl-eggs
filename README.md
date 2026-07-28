# Kalanur Pterodactyl Eggs

Community-maintained Pterodactyl eggs and supporting runtime images.

## Available eggs

| Game | Variant | Status |
|---|---|---|
| [Windrose](games/windrose/native-linux/) | Native Linux | Experimental / testing |

## Repository layout

- `games/` contains importable eggs, installers, tests and game-specific documentation.
- `images/` contains runtime images required by individual eggs. Proprietary game files are not included.
- `.github/workflows/` validates eggs and publishes runtime images.

Each egg documents its installation, migration and update procedure in its own directory.
