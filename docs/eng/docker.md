# Klarspråk

*English translation of the Swedish documentation. The Swedish pages are the original.*

Klarspråk compares how words and phrases are used in everyday Swedish with how they are used in law and by public authorities, with sources on both sides. Visitors can suggest new terms, and suggestions are only published once an administrator has reviewed them. The site itself is in Swedish.

The image contains the whole website and the terms already published. You do not need a Cloudflare account.

## Getting started

The image is on Docker Hub as `docker.io/driftaegis/klarsprak`. The compose file below pulls it from there, so you neither clone the repo nor build anything.

1. **Install Docker.** On Windows and Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/). On Linux: the `docker.io` package (Debian/Ubuntu) or equivalent. Podman works too.
2. **Create a folder** with a file in it named `docker-compose.yml`. Paste the content below.
3. **Fill in the values** in quotes; see [Settings](#settings). The only one you must change is `ADMIN_TOKEN`.
4. **Start** it in that folder: `docker compose up -d`
5. **Open** `http://localhost:8787` (or the server's address and port 8787).

```yaml
services:
  klarsprak:
    image: docker.io/driftaegis/klarsprak:1
    restart: unless-stopped
    ports:
      - "8787:8787"
    environment:
      PUBLIC_HOST: "klarsprak.example.com"
      ADMIN_TOKEN: "change-me-to-a-long-random-string"
      TURNSTILE_SITE_KEY: "your-turnstile-site-key"
      TURNSTILE_SECRET: "your-turnstile-secret-key"
      RATE_LIMIT_KEY: ""
    volumes:
      - klarsprak-data:/data

volumes:
  klarsprak-data:
```

The review queue is at `/admin`. It asks for `ADMIN_TOKEN`.

## Settings

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `PUBLIC_HOST` | Recommended | `localhost` | The host name the site is reached at, without `https://`. Used in links, the sitemap and the Turnstile check. |
| `ADMIN_TOKEN` | Yes | – | Password for the review queue. Use a long random string, for example from `openssl rand -base64 32`. |
| `TURNSTILE_SITE_KEY` | For suggestions | – | Public key for Cloudflare Turnstile (free, needs a Cloudflare account). Without it visitors cannot send suggestions. |
| `TURNSTILE_SECRET` | For suggestions | – | Secret key for Turnstile. |
| `TURNSTILE_HOSTNAMES` | No | `PUBLIC_HOST` | Comma-separated host names the Turnstile answer may come from. |
| `RATE_LIMIT_KEY` | No | `ADMIN_TOKEN` | Key for hashing visitors' IP addresses in the rate limiting. |
| `PORT` | No | `8787` | The port inside the container. |

Turnstile keys are created in the Cloudflare dashboard under **Turnstile → Add site**. Use the same host name as `PUBLIC_HOST`.

### Settings from a file instead

If you do not want values such as passwords in the compose file, put them as `NAME=value` lines in the file `import.env` in the data volume (the one mounted at `/data`) and restart the container. At start the values are saved to `/data/settings.env`, which only the container can read, and `import.env` is deleted. To change a value later, add a new `import.env` with just that line. A line with `NAME=` and no value removes the setting. Values filled in in the compose file take precedence over saved values.

## Data, backup and updates

- All data lives in the volume mounted at `/data`: the database (SQLite) with terms and suggestions.
- **Back up:** `docker compose stop`, copy the volume and run `docker compose start`. The volume's location is shown with `docker volume inspect <folder>_klarsprak-data`.
- **Update:** `docker compose pull && docker compose up -d`. Database migrations run automatically at start.
- **Versions:** the tags follow semver. `1` gives every update within version 1, `1.0` only fixes and `1.0.0` exactly one version. Changes are described in the changelog below.

## HTTPS and publishing on the internet

The container speaks plain HTTP on port 8787. Put it behind a reverse proxy that handles certificates, for example Caddy, Traefik or nginx. Another option is a Cloudflare Tunnel (`cloudflared`), which needs neither an open port nor a certificate of your own. If the site is only for your own network you can use it directly.

## Technical overview

- **Runtime:** Klarspråk is written as a Cloudflare Worker. In the container it runs in `workerd`, the same runtime Cloudflare uses, through `wrangler dev --local` (Miniflare). The D1 database becomes a local SQLite file under `/data/v3/d1/`.
- **Start:** the entrypoint copies a read-only template to `/srv/klarsprak`, fills in `PUBLIC_HOST` and the Turnstile key, runs pending D1 migrations and starts the server. Secrets are passed to wrangler through a private env file (permissions 600) and are never baked into the image.
- **The image** is based on `node:24-trixie-slim` (Node LTS on Debian stable), runs as the `node` user and has a healthcheck against `/`. It only contains source code with placeholders; your values are filled in when the container starts.
- **Security:** responses get a strict CSP, HSTS and the other security headers from the app. The admin API requires `Authorization: Bearer <ADMIN_TOKEN>`, and the token is compared in constant time. Suggestions require Turnstile and are rate limited per hashed IP.
- **Limits:** `wrangler dev` is a development server that runs one process on one machine. That is plenty for a website with normal traffic, but gives neither Cloudflare's automatic scaling nor its global distribution.
- **Troubleshooting:** `docker compose logs -f`. Health status shows with `docker compose ps`.

## Changelog

**1.2.1**
- The admin page calls `/admin/api/` directly, without an extra script that rewrote the addresses. The old address `/admin/critical` no longer exists.
- `ALIAS_HOST` may be written with å, ä or ö.

**1.2.0**
- The documentation is available under `/docs`.

**1.1.3**
- The image is based on `node:24-trixie-slim`: Node 24 (LTS) on Debian 13 (stable).

**1.1.2**
- `tools/render.mjs` writes each filled-in file in a loop until every byte is written, so a short write cannot leave a truncated file.

**1.1.1**
- `tools/render.mjs` reads and writes each file through the same file descriptor, so the file cannot be swapped between the check and the write.

**1.1.0**
- Settings can be given once in `/data/import.env` instead of in the compose file. They are saved to `/data/settings.env` and the import file is deleted.
- The image is built from the project's own repo: `docker build -t klarsprak .`.

**1.0.0**
- First Docker image, with D1 as SQLite under `/data`. The migrations, including the published terms, run at start.
- Fixed: `/admin` ended up in a redirect loop between `/admin` and `/admin.html`.

## License

MIT.
