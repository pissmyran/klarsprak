# Klarspråk

*English translation of the Swedish documentation. The Swedish pages are the original.*

Klarspråk ("plain language") compares how words and phrases are used in everyday Swedish with how they are used in law and by public authorities, with sources on both sides. Visitors can suggest new terms, and a suggestion is only published once an administrator has reviewed it. The site itself is in Swedish.

It runs as a Cloudflare Worker with the terms in D1, or as a ready-made Docker image.

## Tests

```bash
npm install
npm test
npx wrangler deploy --dry-run
```

Local development: `npm run dev`.

## Documentation

Start with the [overview](oversikt.md).

- [Architecture](architecture.md): routing, publishing, review and security
- [Operations](operations.md): migrations, deployment, checks and troubleshooting

## Rules that always apply

- `src/index.js` runs before the static files, so host names, admin, SEO and security headers can never be bypassed.
- A suggestion and a publication are two separate steps; nothing is published without review.
- The published terms only live in D1. The static pages are presentation, never a term database of their own.

## Deploying to your own Cloudflare account

The code contains no account details. Wherever a value of your own is needed, such as a domain, a resource id or keys, there is a placeholder (`__NAME__`). Every placeholder is listed in `cloudflare.example.env`, with a comment on where the value comes from. The values only end up in Cloudflare, never in the repo.

**Option 1: deploy from your own computer.**

1. Create the D1 database (`npx wrangler d1 create <name> --jurisdiction eu`) and a Turnstile site.
2. Copy `cloudflare.example.env` to a file of your own outside the repo and fill in your values.
3. Render a copy with your values: `node tools/render.mjs <your-file.env> build`. The tool stops if a value is missing.
4. Add the secrets once: `npx wrangler secret put ADMIN_TOKEN --cwd build`, and the same for `TURNSTILE_SECRET` and `RATE_LIMIT_KEY`.
5. Run the database migrations: `npx wrangler d1 migrations apply DB --remote --cwd build`.
6. Deploy: `npx wrangler deploy --cwd build`, then delete `build/`.

**Option 2: Workers Builds with the GitHub connection.** Add the values as *build variables* in Cloudflare (Workers → your Worker → Settings → Build), set the build command to `node tools/render.mjs - build && (sh tools/docs-cloudflare.sh build/public || echo "docs skipped")` and the deploy command to `npx wrangler deploy --cwd build`. Build only the production branch. Workers Builds does not run the migrations; see [Operations](operations.md).

## Running with Docker

Klarspråk is available as a ready-made image on Docker Hub, `docker.io/driftaegis/klarsprak`. You do not need to build anything: `docker-compose.yml` names the image like this, and `docker compose up -d` pulls it.

In `docker-compose.yml`:

```yaml
    image: docker.io/driftaegis/klarsprak:1
```

The tag `1` gives every update within version 1; `X.Y` gives only fixes and `X.Y.Z` exactly one version. Every setting is described on the [Docker](docker.md) page, and the changes are listed in [CHANGELOG.md](../../CHANGELOG.md). To build the image yourself from source: `docker build -t klarsprak .` in the repo root.

## Contributing

Questions and ideas go to [Discussions](https://github.com/pissmyran/.github/discussions), bugs and suggestions as issues here. Read [CONTRIBUTING.md](https://github.com/pissmyran/.github/blob/main/CONTRIBUTING.md) before opening a pull request. Report security problems privately through the Security tab.

## License

MIT, see [LICENSE](../../LICENSE).
