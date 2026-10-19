# Klarspråk

Klarspråk är en Cloudflare Worker-baserad webbplats som jämför dokumenterad allmänspråklig betydelse med dokumenterad myndighets- och rättsanvändning av samma uttryck. Publika termer lagras i D1 och publiceras först efter granskning.

## Snabbstart

```bash
npm install
npm test
npx wrangler deploy --dry-run
```

Lokal utveckling:

```bash
npm run dev
```

## Dokumentation

Börja i **[dokumentationsöversikten](docs/index.md)**.

- [Projektkontext](docs/project-context.md) — runtime, publiceringsmodell och state
- [Arkitektur](docs/architecture.md) — Worker/assets/D1, requestflöden och trust boundaries
- [Drift](docs/operations.md) — utveckling, migration, deployment och felsökning

README är avsiktligt kort; detaljerna ligger under `docs/`.

## Viktiga invariants

- `src/index.js` måste köras före assets så att host-, admin-, SEO- och response-policy inte kan kringgås.
- submission och publicering är separata stateövergångar.
- publikt innehåll kommer från D1; statisk HTML är inte canonical termdatabas.

## Operator-wizard

Provider-/credentialförutsättningar verifieras utan att exportera eller skriva secretvärden:

```bash
bash scripts/setup-provider-credentials.sh
```

Wizarden är human-only och skapar eller roterar inga credentials.

## Driftsätta på ett eget Cloudflare-konto

Koden innehåller inga kontouppgifter. Där ett eget värde behövs, som domän, resurs-id eller nycklar, står en platshållare (`__NAMN__`). Alla platshållare finns i `cloudflare.example.env`, med en kommentar om var värdet hämtas. Värdena hamnar bara i Cloudflare, aldrig i repot.

**Alternativ 1: deploy från din egen dator (standard).**

1. Kopiera `cloudflare.example.env` till en egen fil utanför repot och fyll i dina värden.
2. Rendera en kopia med dina värden: `node tools/render.mjs <din-fil.env> build [overlay-katalog]`. Verktyget stoppar om ett värde saknas. Filer i overlay-katalogen kopieras ovanpå, till exempel egna bilder.
3. Lägg in hemligheter en gång, antingen var för sig med `npx wrangler secret put <NAMN>` eller alla på en gång från en JSON-fil med `npx wrangler secret bulk <fil.json>`. Radera filen efteråt.
4. Kör databasmigreringarna (se `docs/`) och deploya: `npx wrangler deploy --cwd build`.
5. Radera `build/`. Cloudflare har nu värdena. Vill du ändra något fyller du i filen igen och upprepar steg 2 och 4.

**Alternativ 2: Workers Builds med GitHub-koppling.** Lägg in värdena som *build variables* i Cloudflare (Workers → din Worker → Settings → Build), sätt byggkommandot till `node tools/render.mjs - build` och deploykommandot till `npx wrangler deploy --cwd build`. Bygg bara produktionsgrenen (stäng av bygg för andra grenar), så skapas inga förhandsversioner. Hemligheter läggs in som i alternativ 1.

## Köra med Docker

Kopiera `docker-compose.yml`, fyll i värdena och kör `docker compose up -d`. Alla inställningar beskrivs i [docker/README.md](docker/README.md). Vill du inte ha värdena i compose-filen kan du lägga dem som `NAMN=värde`-rader i `import.env` i datakatalogen och starta om. Containern sparar dem i `settings.env`, som bara containern kan läsa, och raderar importfilen. Imagen byggs från repots rot med `docker build -t klarsprak .`.

## Bidra

Frågor och idéer tas i [Discussions](https://github.com/VineDrinker/.github/discussions), fel och förslag som issues här. Läs [CONTRIBUTING.md](https://github.com/VineDrinker/.github/blob/main/CONTRIBUTING.md) innan du öppnar en pull request. Säkerhetsproblem rapporteras privat via fliken Security.
