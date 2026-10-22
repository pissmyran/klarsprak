# Arkitektur

## Runtime

Workern `klarsprak` startar i `src/index.js` och konfigureras i `wrangler.jsonc`:

- **Domän:** `PUBLIC_HOST`, plus ett valfritt `ALIAS_HOST` (till exempel en stavning med å) som skickas vidare till huvuddomänen.
- **Statiska filer:** `public/`, med `run_worker_first: true`.
- **D1:** bindningen `DB`.
- **Hemligheter:** `ADMIN_TOKEN`, `TURNSTILE_SECRET` och `RATE_LIMIT_KEY`.
- **Loggning:** alla loggar (sampling 1, med anropsloggar), spårningar till 1 %, frågesträngar maskeras och Workers Issues är på.

## Koden

- **`src/index.js`** är den yttre policyn: aliasdomänen skickas till huvuddomänen, adminvägarna mappas, SEO-metadata läggs till och säkerhetshuvudena sätts på varje svar (`src/response-policy.js`).
- **`src/worker.js`** är applikationen: publika termer, förslag, granskning, D1 och vidarelämning till de statiska filerna.

## Workern först

Utan `run_worker_first` skulle Cloudflare kunna svara med en statisk fil innan Workern hinner skicka aliasdomänen vidare, styra admin, sätta SEO och lägga på säkerhetshuvuden. Att byta till att de statiska filerna går först är därför en säkerhetsändring.

## Admin

Gränssnittet ligger på `/admin`, och API:t på `/admin/api/…`. Båda ligger under `/admin`, så en Cloudflare Access-applikation för den sökvägen kan skydda allt som ett extra lager. Workern skriver om `/admin/api/…` internt till `/api/admin/…`, och ett direkt anrop till `/api/admin/…` skickas vidare till `/admin/api/…`. Alla anrop kräver `Authorization: Bearer <ADMIN_TOKEN>`, som jämförs i konstant tid, och adminsvaren cacheas aldrig.

`/admin` släpps igenom till de statiska filerna, som serverar `admin.html` där. Skriv aldrig om den till `/admin.html`; då uppstår en omdirigeringsloop.

## API

| Anrop | Gör |
| --- | --- |
| `GET /api/terms` | De publicerade termerna. |
| `POST /api/submit` | Ett nytt förslag (Turnstile och hastighetsbegränsning). |
| `GET /admin/api/queue` | Granskningskön. |
| `GET /admin/api/terms` | Alla termer, även opublicerade. |
| `POST /admin/api/review/:id` | Granskar ett förslag. |
| `PUT /admin/api/terms/:id` | Redigerar en term. |
| `POST /admin/api/terms/:id/status` | Publicerar eller arkiverar en term. |

## Förslag

`POST /api/submit` validerar förslaget, kontrollerar Turnstile mot `TURNSTILE_HOSTNAMES`, begränsar till fem förslag per timme och IP-adress (IP-adressen sparas bara som en HMAC med `RATE_LIMIT_KEY`, eller `ADMIN_TOKEN` om den saknas) och sparar förslaget i granskningskön. Det publiceras aldrig automatiskt.

## D1

D1 är den enda sanningen om publicerade termer och granskningen. Workern använder D1 Sessions API: `GET /api/terms` läser från närmaste replik, och allt annat från primären. Därför kan läsrepliker vara påslagna. Databasen ska vara skapad med `jurisdiction=eu`.

## Säkerhetshuvuden

- **CSP** tillåter inte inbäddade skript i allmänhet. `script-src` får en ny nonce för varje svar, så att Cloudflares egna inbäddade skript (som JavaScript Detection) kan bära samma nonce. Den enda externa källan för skript och ramar är Turnstile på `https://challenges.cloudflare.com`.
- **Skript** ligger som egna filer, `/app.js` för den publika sidan och `/admin.js` för admin.
- **Dokumentationen** under `/docs` byggs in i de statiska filerna vid driftsättning, och dess inbäddade skript får svarets nonce.

## SEO och cache

De publika sidorna får canonical-länk, robots och beskrivning från Workern. Admin och andra icke-publika sidor indexeras inte och cacheas inte.

## Tema

Det finns tre teman: `legacy` (standard), `forest` (med etiketten från `SITE_FAMILY`) och `blackout`. Valet sparas i `localStorage["<prefix>.theme"]` och cookien `<prefix>_theme`, där prefixet är `THEME_KEY_PREFIX` och cookien kan delas med `THEME_COOKIE_DOMAIN`. Temat ändrar bara utseendet och påverkar aldrig admin, Turnstile eller publiceringen.

## PWA

Sidan har ett webbmanifest, ikoner i 192 och 512 pixlar och en service worker. Service workern hämtar alltid från nätet och cachear ingenting, varken sidor, termer, förslag eller admin. Den är bara till för att sidan ska kunna installeras.
