# Overview

```text
Browser
    |
    v
src/index.js     host names, admin routing, SEO and security headers
    |
    v
src/worker.js ──> D1 (DB)    published terms, suggestions and review
    |
    +──> ASSETS (public/)    the pages, scripts and styles
```

| Topic | Page |
| --- | --- |
| Routing, publishing, review, security and PWA | [Architecture](architecture.md) |
| Local development, migrations, deployment, checks and troubleshooting | [Operations](operations.md) |

## The three flows

- **Reading:** the page fetches the published terms from `GET /api/terms`. D1 is the only source; the page only shows what the API returns.
- **Suggesting:** a visitor sends a suggestion with `POST /api/submit`. Turnstile protects the form, and the suggestion goes into the review queue without being published.
- **Review:** the administrator reads the queue at `/admin` and edits, approves, publishes or archives with explicit steps.

## Before you change anything

- **Routes, host names or SEO:** read [Architecture](architecture.md) and [Operations](operations.md).
- **The D1 schema or publishing:** write a new migration and update [Architecture](architecture.md).
- **Suggestions, review or admin:** read [Architecture](architecture.md) and check the security boundaries afterwards.
