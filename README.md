# Klarspråk

**Dokumentation:** [pissmyran.github.io/klarsprak](https://pissmyran.github.io/klarsprak/) – start, dokumentation och Docker på en sida med sök.

Klarspråk jämför hur ord och uttryck används i vanlig svenska med hur de används i lag och hos myndigheter, med källor på båda sidor. Besökare kan föreslå nya termer, och ett förslag publiceras först när en administratör har granskat det.

Det körs som en Cloudflare Worker med termerna i D1, eller som en färdig Docker-image.

## Tester

```bash
npm install
npm test
npx wrangler deploy --dry-run
```

Lokal utveckling: `npm run dev`.

## Dokumentation

Börja i [översikten](docs/oversikt.md).

- [Arkitektur](docs/architecture.md): routing, publicering, granskning och säkerhet
- [Drift](docs/operations.md): migreringar, driftsättning, kontroller och felsökning

## Regler som alltid gäller

- `src/index.js` körs före de statiska filerna, så att värdnamn, admin, SEO och säkerhetshuvuden aldrig kan förbigås.
- Ett förslag och en publicering är två separata steg; inget publiceras utan granskning.
- De publicerade termerna finns bara i D1. De statiska sidorna är presentation, aldrig en egen termdatabas.

## Driftsätta på ett eget Cloudflare-konto

Koden innehåller inga kontouppgifter. Där ett eget värde behövs, som domän, resurs-id eller nycklar, står en platshållare (`__NAMN__`). Alla platshållare finns i `cloudflare.example.env`, med en kommentar om var värdet hämtas. Värdena hamnar bara i Cloudflare, aldrig i repot.

**Alternativ 1: deploy från din egen dator.**

1. Skapa D1-databasen (`npx wrangler d1 create <namn> --jurisdiction eu`) och en Turnstile-sajt.
2. Kopiera `cloudflare.example.env` till en egen fil utanför repot och fyll i dina värden.
3. Rendera en kopia med dina värden: `node tools/render.mjs <din-fil.env> build`. Verktyget stoppar om ett värde saknas.
4. Lägg in hemligheterna en gång: `npx wrangler secret put ADMIN_TOKEN --cwd build`, och samma för `TURNSTILE_SECRET` och `RATE_LIMIT_KEY`.
5. Kör databasmigreringarna: `npx wrangler d1 migrations apply DB --remote --cwd build`.
6. Deploya: `npx wrangler deploy --cwd build`, och radera sedan `build/`.

**Alternativ 2: Workers Builds med GitHub-koppling.** Lägg in värdena som *build variables* i Cloudflare (Workers → din Worker → Settings → Build), sätt byggkommandot till `node tools/render.mjs - build && (sh tools/docs-cloudflare.sh build/public || echo "docs skipped")` och deploykommandot till `npx wrangler deploy --cwd build`. Bygg bara produktionsgrenen. Workers Builds kör inte migreringarna; se [Drift](docs/operations.md).

## Köra med Docker

Klarspråk finns som färdig image på Docker Hub, `docker.io/driftaegis/klarsprak`. Du behöver inte bygga något själv: i `docker-compose.yml` står imagen så här, och `docker compose up -d` hämtar den.

I `docker-compose.yml`:

```yaml
    image: docker.io/driftaegis/klarsprak:1
```

Taggen `1` ger alla uppdateringar inom version 1; `X.Y` ger bara rättningar och `X.Y.Z` exakt en version. Alla inställningar beskrivs i [docker/README.md](docker/README.md), och ändringarna listas i [CHANGELOG.md](CHANGELOG.md). Vill du bygga imagen själv från källkoden: `docker build -t klarsprak .` i repots rot.

## Bidra

Frågor och idéer tas i [Discussions](https://github.com/pissmyran/.github/discussions), fel och förslag som issues här. Läs [CONTRIBUTING.md](https://github.com/pissmyran/.github/blob/main/CONTRIBUTING.md) innan du öppnar en pull request. Säkerhetsproblem rapporteras privat via fliken Security.

## Licens

MIT, se [LICENSE](LICENSE).
