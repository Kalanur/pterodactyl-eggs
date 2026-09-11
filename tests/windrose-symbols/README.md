# Windrose symbol-removal test

This branch tests pterodactyl/yolks#79 at e4fb595fc0f8c8582c686276613388b959153cbf.
The runtime directory is an unmodified snapshot of that PR. prepare.py creates a
test Dockerfile with a pinned Debian digest, and removes only Linux *.debug and
*.sym in the upstream stage for the stripped variant. The original production
runtime and its latest tag are not modified.

The Egg is derived from pterodactyl/game-eggs#604 at
8a892f863b1de1a2237baf56e98cd092f6bfe8ad. It is a test derivative, not a new Panel export.

## Automated checks

Push this branch to run Test Windrose symbol removal. Both variants use the same
pinned publisher and Debian digests. Each job builds its image, checks helper
syntax and configuration generation, measures uncompressed image size and logical
payload bytes, and records SHA-256 hashes of all application files. The comparison
must find exactly the removed symbols and identical retained files and symlinks.
The apt package versions are resolved at build time; image-size differences can
include package changes if the Debian repositories change between the two jobs.

Images use the existing GHCR package, with symbol-test-baseline and
symbol-test-stripped tags. These aliases update only after successful comparison.
Commit-specific tags and registry digests are recorded in the workflow artifacts.
Package visibility and Actions write access are inherited from the existing GHCR
package configuration; a public GitHub repository alone does not ensure public images.

## Pterodactyl validation (pending)

1. Wait for a green comparison job. Download the Egg from the workflow artifact
   or this directory and import it as a separate Egg.
2. Create a separate server with an unused allocation and isolated saves. Select
   the symbol-test-baseline image. Do not reuse a production server volume.
3. Verify fresh installation, world creation, P2P and Direct Connect, clean stop,
   and restart with persistent configuration and saves. Record logs and image digest.
4. Stop the test server, back up its test data, and switch to symbol-test-stripped.
   Repeat connection and save/restart checks, including preservation of the world
   and generated IDs. Also test a fresh installation with the stripped image.
5. Record results next to the automated size comparison. Only then apply the
   five-line Dockerfile change to Kalanur/yolks:add-windrose-runtime.

On Bishop, the publisher image pulled solely for the earlier local build can be
removed by its exact digest if no container uses it. Do not remove the production
ghcr.io/kalanur/pterodactyl-windrose-native image. Load only one test image at a time
and check free Docker space before pulling. Local BuildKit archives are unrelated
to this GitHub build and can remain in the external test directory.

No server or client connection test has yet been completed for the stripped image.
