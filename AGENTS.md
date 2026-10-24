# AGENTS.md

- Gemensamma regler för arbetssätt, deploy, loggning, kostnader och Docker finns i [CLAUDE.md](CLAUDE.md). Arbetet sker på en egen gren per session; `main` ändras bara genom en PR från den grenen med squash merge.
- Läs [docs/architecture.md](docs/architecture.md) och [docs/operations.md](docs/operations.md) före större ändringar.
- Behåll att Workern går först (`run_worker_first`); den styr värdnamn, admin, SEO och säkerhetshuvuden. `/admin` släpps igenom till de statiska filerna, som serverar `admin.html` där; skriv inte om den till `/admin.html`.
- Ett förslag får aldrig publiceras utan granskningssteget.
- Kör `node --test` och `npx wrangler deploy --dry-run` före push.
- Inga personliga värden i koden, bara platshållare (`__NAMN__`) som deklareras i `cloudflare.example.env`. Uppdatera `CHANGELOG.md` och versionen i `package.json` vid varje ny image.
- Hemligheter och adminuppgifter hamnar aldrig i Git eller publik dokumentation.
