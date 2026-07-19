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

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/xStzAa?referralCode=hbcoEC&utm_medium=integration&utm_source=template&utm_campaign=generic)

## Deploy

1. Fork or clone this repo, push to your GitHub.
2. Railway → New Project → Deploy from GitHub repo → select it. Railway
   detects the Dockerfile and builds.
3. **Volume**: the template provisions it at `/readeck` automatically
   (SQLite DB + article content). Deploying from the repo directly
   instead of the template? Attach one manually — right-click the
   service tile → Attach Volume — or your data dies on every deploy.
4. Service → Settings → Networking → Generate Domain, target port `8000`.
   A custom domain is worth setting up front: the instance URL gets baked
   into every client (browser extension, mobile shortcuts, e-reader
   plugins), and a domain you own makes future migration a DNS change.
5. Railway's Serverless setting (formerly App Sleeping) may be enabled by
   default. `railway.json` here sets `sleepApplication: false`, and config
   in code overrides the dashboard per deployment — but flip the toggle
   off in Settings → Deploy → Serverless too, so the UI reflects reality.
   Read-later clients that sync in short bursts (KOReader on e-ink,
   iOS Shortcuts) report sleep/wake drops as network errors.
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
`trusted_proxies` — don't cargo-cult it from older guides.

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