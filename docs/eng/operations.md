# Operations

## Local development

```bash
npm install
npx wrangler d1 migrations apply DB --local
npm run dev
```

The repo has no `package-lock.json`, so install with `npm install`, not `npm ci`.

## Checks before pushing

```bash
npm test
npx wrangler deploy --dry-run
```

Also try the flows by hand when a change touches routing, suggestions or admin.

## Deployment

Production is deployed from a rendered copy, either from your computer or with Workers Builds when a PR is merged to `main`; see the [home page](index.md).

## Migrations

Workers Builds does not run the D1 migrations, so they are run by hand from a rendered copy:

```bash
node tools/render.mjs <your-file.env> build
npx wrangler d1 migrations apply DB --remote --cwd build
```

- Schema changes are only made with new migrations, never directly in production.
- A migration that adds runs before the new Worker is deployed, one that removes runs after.

## Check after deployment

From the same rendered copy:

```bash
node build/scripts/check-production-domain.mjs
```

It checks that the home page answers `200`, that `/api/terms` returns JSON with a list of terms and, if `ALIAS_HOST` is set, that the alias domain forwards to the main domain with `301`. Each check is tried up to five times.

Also check:

- **Suggestions:** that a suggestion lands in the review queue without being published, and that the CSP allows Turnstile but not `'unsafe-inline'` in `script-src`.
- **Admin:** that `/admin/api/…` requires `ADMIN_TOKEN` and that publishing and archiving only happen through explicit steps.
- **SEO:** that the public pages have canonical and robots, and that `/admin` is neither indexed nor cached.

## D1

- The database must be created with `jurisdiction=eu`. It cannot be changed afterwards, so a switch is done as an export and import into a new EU database before the binding is changed.
- Read replicas may be on (`auto`), since the Worker uses the Sessions API. The replicas stay within the EU.

## Troubleshooting

**Empty or wrong term list:** check, in this order, the domain and route, `/api/terms`, the published terms in D1 and last the page itself.

**Suggestions fail:** check the suggestion's data, Turnstile (keys and `TURNSTILE_HOSTNAMES`), the write to D1 and the Worker's log.

**Admin does not work:** check `ADMIN_TOKEN` and, if you use it, the Access application for `/admin` before changing any data. Never make the admin API more public to solve an access problem.

Query strings are masked in the logs even while troubleshooting; never put sensitive parameters in logs.
