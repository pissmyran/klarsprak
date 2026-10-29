# Architecture

## Runtime

The Worker `klarsprak` starts in `src/index.js` and is configured in `wrangler.jsonc`:

- **Domain:** `PUBLIC_HOST`, plus an optional `ALIAS_HOST` (for example a spelling with å) that is forwarded to the main domain.
- **Static files:** `public/`, with `run_worker_first: true`.
- **D1:** the binding `DB`.
- **Secrets:** `ADMIN_TOKEN`, `TURNSTILE_SECRET` and `RATE_LIMIT_KEY`.
- **Logging:** every log (sampling 1, with invocation logs), traces at 1 %, query strings masked and Workers Issues on.

## The code

- **`src/index.js`** is the outer policy: the alias domain is forwarded to the main domain, the admin paths are mapped, SEO metadata is added and the security headers are set on every response (`src/response-policy.js`).
- **`src/worker.js`** is the application: public terms, suggestions, review, D1 and handing off to the static files.

## Worker first

Without `run_worker_first`, Cloudflare could answer with a static file before the Worker forwards the alias domain, routes admin, sets SEO and adds security headers. Switching to static files first is therefore a security change.

## Admin

The interface lives at `/admin`, and the API at `/admin/api/…`. Both are under `/admin`, so a Cloudflare Access application for that path can protect everything as an extra layer. The Worker rewrites `/admin/api/…` internally to `/api/admin/…`, and a direct request to `/api/admin/…` is forwarded to `/admin/api/…`. Every request requires `Authorization: Bearer <ADMIN_TOKEN>`, compared in constant time, and admin responses are never cached.

`/admin` is passed through to the static files, which serve `admin.html` there. Never rewrite it to `/admin.html`; that creates a redirect loop.

## API

| Request | Does |
| --- | --- |
| `GET /api/terms` | The published terms. |
| `POST /api/submit` | A new suggestion (Turnstile and rate limiting). |
| `GET /admin/api/queue` | The review queue. |
| `GET /admin/api/terms` | Every term, including unpublished ones. |
| `POST /admin/api/review/:id` | Reviews a suggestion. |
| `PUT /admin/api/terms/:id` | Edits a term. |
| `POST /admin/api/terms/:id/status` | Publishes or archives a term. |

## Suggestions

`POST /api/submit` validates the suggestion, checks Turnstile against `TURNSTILE_HOSTNAMES`, limits to five suggestions per hour and IP address (the IP address is only saved as an HMAC with `RATE_LIMIT_KEY`, or `ADMIN_TOKEN` if that is missing) and saves the suggestion in the review queue. It is never published automatically.

## D1

D1 is the single source of truth for published terms and the review. The Worker uses the D1 Sessions API: `GET /api/terms` reads from the nearest replica, and everything else from the primary. That is why read replicas can be turned on. The database must be created with `jurisdiction=eu`.

## Security headers

- **The CSP** does not allow inline scripts in general. `script-src` gets a new nonce for every response, so Cloudflare's own inline scripts (such as JavaScript Detection) can carry the same nonce. The only external source for scripts and frames is Turnstile at `https://challenges.cloudflare.com`.
- **Scripts** are separate files, `/app.js` for the public page and `/admin.js` for admin.
- **The documentation** under `/docs` is built into the static files at deployment, and its inline scripts get the response's nonce.

## SEO and cache

The public pages get a canonical link, robots and description from the Worker. Admin and other non-public pages are not indexed and not cached.

## Theme

There are three themes: `legacy` (default), `forest` (with the label from `SITE_FAMILY`) and `blackout`. The choice is saved in `localStorage["<prefix>.theme"]` and the cookie `<prefix>_theme`, where the prefix is `THEME_KEY_PREFIX` and the cookie can be shared with `THEME_COOKIE_DOMAIN`. The theme only changes the look and never affects admin, Turnstile or publishing.

## PWA

The site has a web manifest, icons at 192 and 512 pixels and a service worker. The service worker always fetches from the network and caches nothing: no pages, terms, suggestions or admin. It only exists so the site can be installed.
