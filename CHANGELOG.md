# Changelog

Versions follow [semver](https://semver.org). The Docker image is tagged `X.Y.Z`, `X.Y`, `X` and `latest`.

## 1.1.0 – 2026-10-18

- Settings can be given once in `/data/import.env` instead of in `docker-compose.yml`: they are saved to `/data/settings.env`, readable only by the container, and the import file is deleted. `NAME=` removes a setting; non-empty compose variables still win.
- The project now lives in its own repository, so the image builds from the repo root with `docker build -t klarsprak .`.

## 1.0.0 – 2026-10-17

- First Docker image: the Worker runs in workerd via `wrangler dev --local`, with D1 as SQLite in `/data`. Migrations, including the published terms, are applied on start.
- `docker-compose.yml` with placeholders for host name, admin token and Turnstile keys.
- Fixed: `/admin` looped between `/admin` and `/admin.html`; `/admin` now goes straight to the page and `/admin/` redirects to it.
