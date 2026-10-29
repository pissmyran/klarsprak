# AGENTS.md – klarsprak

En sajt som jämför vardagssvenska med juridiskt och myndighetsspråk, plus en Docker-bild för egen drift.

Läs de gemensamma reglerna i början av varje session: [GOVERNANCE.md](https://raw.githubusercontent.com/pissmyran/.github/main/GOVERNANCE.md) och [SERVICES.md](https://raw.githubusercontent.com/pissmyran/.github/main/SERVICES.md). Läs [docs/architecture.md](docs/architecture.md) och [docs/operations.md](docs/operations.md) före större ändringar.

## Kommandon

```bash
npm install && node --test
npx wrangler deploy --dry-run
```

Båda krävs före push.

## Regler

- **Ingång:** `src/index.js`. Hanterare: fetch. Bindningar: D1, Assets.
- **API:** publika `/api/terms` och `/api/submit` (Turnstile) och en granskningskö i `/admin` med bearer-token.
- **Routing:** behåll att Workern går först (`run_worker_first`); den styr värdnamn, admin, SEO och säkerhetshuvuden. `/admin` släpps igenom till de statiska filerna, som serverar `admin.html` där; skriv inte om den till `/admin.html`.
- **Ett förslag** publiceras aldrig utan granskningssteget.
- **Dokumentationen** publiceras också under `/docs` av appens egen Worker: Workers Builds kör `node tools/render.mjs - build && (sh tools/docs-cloudflare.sh build/public || echo "docs skipped")`, och Workern ger sajtens inline-skript CSP-noncen (`isDocsPath` i `src/index.js`).
- **Release:** versionen finns i `package.json`.
- **Extra noggrant:** inskick och Turnstile, admin-token, CSP och migreringar.
