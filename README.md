# readeck-railway

A minimal shim for deploying [Readeck](https://readeck.org) — a self-hosted
read-it-later service — on [Railway](https://railway.com).

## Why this exists

Railway's "Deploy a Docker image" flow only accepts images from Docker Hub,
GHCR, Quay.io, and GitLab's registry. Readeck publishes its official image to
Codeberg's container registry (`codeberg.org/readeck/readeck`), so pasting
that path returns `Invalid Docker image`. A Dockerfile build has no such
restriction: `FROM` pulls from any public registry. This repo is that
one-line bridge, plus the Railway config to go with it.

<!-- After first deploy: Railway → project → Create template → publish,
     then replace TEMPLATE_CODE below and delete this comment. -->
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/workspace/templates/f0c75b2c-f1d5-4fec-b510-d0613a85208d)

## Deploy

1. Fork or clone this repo, push to your GitHub.
2. Railway → New Project → Deploy from GitHub repo → select it. Railway
   detects the Dockerfile and builds.
3. **Attach a volume** mounted at `/readeck` (service → right-click →
   Attach Volume). This holds the SQLite DB and all article content —
   without it, your data dies on every deploy.
4. Service → Settings → Networking → Generate Domain, target port `8000`.
   A custom domain is worth setting up front: the instance URL gets baked
   into every client (browser extension, mobile shortcuts, e-reader
   plugins), and a domain you own makes future migration a DNS change.
5. If your plan has app sleeping, disable it for this service. Clients that
   sync in short bursts (e.g. KOReader plugins on e-ink devices) handle
   cold starts poorly.
6. Open the URL, create your admin account, then generate an API token
   (profile → API Tokens) for programmatic clients.

## Configuration

Server settings are environment variables (`READECK_*`); the Dockerfile sets
host and port, everything else is optional. See the
[Readeck configuration docs](https://readeck.org/en/docs/configuration).

### Behind Railway's proxy

Railway terminates TLS at its edge, so set these as service environment
variables once you know your domain:

| Variable | Value | Why |
|---|---|---|
| `READECK_SERVER_BASE_URL` | `https://your.domain` | Correct scheme in generated URLs; fixes CSRF/login failures behind TLS-terminating proxies |
| `READECK_ALLOWED_HOSTS` | `your.domain` | Host-header allowlist; recommended hardening |
| `READECK_TRUSTED_PROXIES` | only if login returns 403 | Networks allowed to set `X-Forwarded-*`; defaults to private ranges, widen only if needed |

Note: `READECK_USE_X_FORWARDED` was removed in Readeck 0.16 and replaced by
`trusted_proxies`.

## Upgrading

Pin a release tag in the Dockerfile and bump it in a commit. Sticking with
`:latest` works but couples upgrades to Railway's layer-cache behavior,
which makes "what version am I running" a guess.

## Migrating off Railway

Readeck's state is the `/readeck` volume. Copy its contents to the data
directory of any other deployment (bare binary, Docker, home server) and
point your DNS at the new host. Done.

## License

MIT