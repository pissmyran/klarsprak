# Drift

## Lokal utveckling

```bash
npm install
npx wrangler d1 migrations apply DB --local
npm run dev
```

Repot har ingen `package-lock.json`, så installera med `npm install`, inte `npm ci`.

## Kontroller före push

```bash
npm test
npx wrangler deploy --dry-run
```

Prova dessutom flödena för hand när en ändring rör routing, förslag eller admin.

## Driftsättning

Produktionen driftsätts från en renderad kopia, antingen från din dator eller med Workers Builds när en PR mergas till `main`; se `README.md`.

## Migreringar

Workers Builds kör inte D1-migreringarna, så de körs för hand från en renderad kopia:

```bash
node tools/render.mjs <din-fil.env> build
npx wrangler d1 migrations apply DB --remote --cwd build
```

- Schemaändringar görs bara med nya migreringar, aldrig direkt i produktionen.
- En migrering som lägger till körs före deployen av den nya Workern, en som tar bort efter.

## Kontroll efter driftsättning

Från samma renderade kopia:

```bash
node build/scripts/check-production-domain.mjs
```

Den kontrollerar att startsidan svarar `200`, att `/api/terms` ger JSON med en lista med termer och, om `ALIAS_HOST` är satt, att aliasdomänen skickar vidare till huvuddomänen med `301`. Varje kontroll görs upp till fem gånger.

Kontrollera också:

- **Förslag:** att ett förslag hamnar i granskningskön utan att publiceras, och att CSP:n tillåter Turnstile men inte `'unsafe-inline'` i `script-src`.
- **Admin:** att `/admin/api/…` kräver `ADMIN_TOKEN` och att publicering och arkivering bara sker med uttryckliga steg.
- **SEO:** att de publika sidorna har canonical och robots, och att `/admin` varken indexeras eller cacheas.

## D1

- Databasen ska vara skapad med `jurisdiction=eu`. Det går inte att ändra efteråt, så ett byte görs som export och import till en ny EU-databas innan bindningen byts.
- Läsrepliker får vara påslagna (`auto`), eftersom Workern använder Sessions API. Replikerna stannar inom EU.

## Felsökning

**Tom eller fel termlista:** kontrollera i den här ordningen domän och route, `/api/terms`, de publicerade termerna i D1 och sist sidan själv.

**Förslag misslyckas:** kontrollera förslagets data, Turnstile (nycklar och `TURNSTILE_HOSTNAMES`), skrivningen till D1 och Workerns logg.

**Admin fungerar inte:** kontrollera `ADMIN_TOKEN` och, om du använder den, Access-applikationen för `/admin` innan du ändrar någon data. Gör aldrig admin-API:t mer publikt för att lösa ett åtkomstproblem.

Frågesträngarna maskeras i loggarna även vid felsökning; lägg aldrig känsliga parametrar i loggar.
