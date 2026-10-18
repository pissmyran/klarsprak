# AGENTS.md

- Gemensamma regler för arbetssätt, deploy, loggning, kostnader och Docker finns i [CLAUDE.md](CLAUDE.md). Arbetet sker lokalt; GitHub är sparpunkten och färdiga delar går in i `main` via en pull request.
- Läs [docs/project-context.md](docs/project-context.md), [docs/architecture.md](docs/architecture.md) och [docs/operations.md](docs/operations.md) före materiella ändringar. Domänkonventionen står i [docs/agents/domain.md](docs/agents/domain.md).
- Bevara Worker-first-routingen; den upprätthåller canonical host, adminrouting och response policy. `/admin` släpps igenom till Workers Assets (som serverar `admin.html` där); skriv inte om den till `/admin.html`.
- Publika förslag får inte bli publicerade utan granskningssteget.
- Kör `node --test` och `npx wrangler deploy --dry-run` före deploy.
- Koden innehåller inga personliga värden, bara platshållare (`__NAMN__`) som deklareras i `cloudflare.example.env` och fylls i av `tools/render.mjs` vid deploy och av `docker/entrypoint.sh` i containern. Se regeln i `CLAUDE.md`. Uppdatera `CHANGELOG.md` och versionen i `package.json` vid varje ny image.
- Lägg aldrig secrets eller känslig admin-/authorizationkonfiguration i repository eller publik dokumentation.
