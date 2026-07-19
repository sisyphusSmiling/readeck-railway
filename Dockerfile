# Readeck publishes images to Codeberg's container registry, which Railway's
# image-deploy flow doesn't support (Docker Hub / GHCR / Quay / GitLab only).
# A Dockerfile build pulls from any public registry, so this shim is the bridge.
#
# Pin a version tag (see https://codeberg.org/readeck/readeck/releases) for
# reproducible builds; with :latest, Railway's layer cache may serve a stale
# base on rebuild. Bump the tag in a commit to upgrade deliberately.
FROM codeberg.org/readeck/readeck:latest

ENV READECK_SERVER_HOST=0.0.0.0 \
    READECK_SERVER_PORT=8000

# Railway's runtime requires the working directory to exist as a filesystem
# layer in the image; the upstream image's /readeck apparently isn't
# materialized in a way Railway accepts. WORKDIR creates the directory
# (no shell needed, works even on scratch-based images).
WORKDIR /readeck

EXPOSE 8000