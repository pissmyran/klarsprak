# Changelog

Versions follow [semver](https://semver.org). The Docker image is tagged `X.Y.Z`, `X.Y`, `X` and `latest`.

## 1.2.1 – 2026-10-22

- The admin page calls `/admin/api/` directly; the script that rewrote its requests from `/api/admin/` is gone, and the old `/admin/critical` address no longer exists.
- `ALIAS_HOST` may be written with å, ä or ö; it is compared in the same ASCII (punycode) form as the request's host name.

## 1.2.0 – 2026-10-21

- The Worker serves the documentation site under `/docs` (built into the static assets at deploy) and gives its inline scripts the response's CSP nonce. `/docs` pages are indexable.

## 1.1.3 – 2026-10-21

- The image runs on `node:24-trixie-slim`: Node 24, the current LTS, on Debian 13 (stable).

## 1.1.2 – 2026-10-19

- `tools/render.mjs` writes each filled-in file in a loop until every byte is written, so a short write can no longer leave a truncated file behind.

## 1.1.1 – 2026-10-19

- `tools/render.mjs` checks the size of, reads and rewrites each file through one file descriptor, so a file cannot be swapped between the check and the write (CodeQL js/file-system-race).

## 1.1.0 – 2026-10-18

- Settings can be given once in `/data/import.env` instead of in `docker-compose.yml`: they are saved to `/data/settings.env`, readable only by the container, and the import file is deleted. `NAME=` removes a setting; non-empty compose variables still win.
- The project now lives in its own repository, so the image builds from the repo root with `docker build -t klarsprak .`.

## 1.0.0 – 2026-10-17

- First Docker image: the Worker runs in workerd via `wrangler dev --local`, with D1 as SQLite in `/data`. Migrations, including the published terms, are applied on start.
- `docker-compose.yml` with placeholders for host name, admin token and Turnstile keys.
- Fixed: `/admin` looped between `/admin` and `/admin.html`; `/admin` now goes straight to the page and `/admin/` redirects to it.
