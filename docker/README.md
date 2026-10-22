# Klarspråk

Klarspråk jämför hur ord och uttryck används i vanlig svenska med hur de används i lag och hos myndigheter, med källor på båda sidor. Besökare kan föreslå nya termer, och förslagen publiceras först när en administratör har granskat dem.

Imagen innehåller hela webbplatsen och de redan publicerade termerna. Du behöver inget Cloudflare-konto.

## Kom igång

1. **Installera Docker.** På Windows och Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/). På Linux: paketet `docker.io` (Debian/Ubuntu) eller motsvarande. Podman fungerar också.
2. **Skapa en mapp** och en fil i den som heter `docker-compose.yml`. Klistra in innehållet nedan.
3. **Fyll i värdena** som står inom citattecken, se [Inställningar](#inställningar). Det enda du måste ändra är `ADMIN_TOKEN`.
4. **Starta** i den mappen: `docker compose up -d`
5. **Öppna** `http://localhost:8787` (eller serverns adress och port 8787).

```yaml
services:
  klarsprak:
    image: docker.io/driftaegis/klarsprak:1
    restart: unless-stopped
    ports:
      - "8787:8787"
    environment:
      PUBLIC_HOST: "klarsprak.example.com"
      ADMIN_TOKEN: "change-me-to-a-long-random-string"
      TURNSTILE_SITE_KEY: "your-turnstile-site-key"
      TURNSTILE_SECRET: "your-turnstile-secret-key"
      RATE_LIMIT_KEY: ""
    volumes:
      - klarsprak-data:/data

volumes:
  klarsprak-data:
```

Granskningskön finns på `/admin`. Den frågar efter `ADMIN_TOKEN`.

## Inställningar

| Variabel | Krävs | Standard | Betydelse |
|---|---|---|---|
| `PUBLIC_HOST` | Rekommenderas | `localhost` | Värdnamnet sidan nås på, utan `https://`. Används i länkar, sitemap och Turnstile-kontrollen. |
| `ADMIN_TOKEN` | Ja | – | Lösenord för granskningskön. Använd en lång slumpsträng, till exempel från `openssl rand -base64 32`. |
| `TURNSTILE_SITE_KEY` | För förslag | – | Publik nyckel för Cloudflare Turnstile (gratis, kräver ett Cloudflare-konto). Utan den kan besökare inte skicka förslag. |
| `TURNSTILE_SECRET` | För förslag | – | Hemlig nyckel för Turnstile. |
| `TURNSTILE_HOSTNAMES` | Nej | `PUBLIC_HOST` | Kommaseparerade värdnamn som Turnstile-svaret får komma från. |
| `RATE_LIMIT_KEY` | Nej | `ADMIN_TOKEN` | Nyckel för att hasha besökares IP-adresser i hastighetsbegränsningen. |
| `PORT` | Nej | `8787` | Porten inne i containern. |

Turnstile-nycklar skapas i Cloudflares instrumentpanel under **Turnstile → Add site**. Ange samma värdnamn som `PUBLIC_HOST`.

### Inställningar från en fil i stället

Vill du inte ha värden som lösenord i compose-filen lägger du dem som `NAMN=värde`-rader i filen `import.env` i datavolymen (den som monteras på `/data`) och startar om containern. Vid starten sparas värdena i `/data/settings.env`, som bara containern kan läsa, och `import.env` raderas. För att ändra ett värde senare lägger du en ny `import.env` med bara den raden. En rad med `NAMN=` och inget värde tar bort inställningen. Värden som är ifyllda i compose-filen gäller före sparade värden.

## Data, säkerhetskopiering och uppdatering

- All data ligger i volymen som är monterad på `/data`: databasen (SQLite) med termer och förslag.
- **Säkerhetskopiera:** `docker compose stop`, kopiera volymen och kör `docker compose start`. Volymens plats visas med `docker volume inspect <mapp>_klarsprak-data`.
- **Uppdatera:** `docker compose pull && docker compose up -d`. Databasmigreringar körs automatiskt vid start.
- **Versioner:** taggarna följer semver. `1` ger alla uppdateringar inom version 1, `1.0` bara rättningar och `1.0.0` exakt en version. Ändringar beskrivs i changeloggen nedan.

## HTTPS och publicering på internet

Containern talar vanlig HTTP på port 8787. Lägg den bakom en omvänd proxy som sköter certifikat, till exempel Caddy, Traefik eller nginx. Ett alternativ är en Cloudflare Tunnel (`cloudflared`), som kräver varken öppen port eller eget certifikat. Om sidan bara ska nås från ditt eget nätverk kan du använda den direkt.

## Teknisk översikt

- **Runtime:** Klarspråk är skrivet som en Cloudflare Worker. I containern körs den i `workerd`, samma runtime som Cloudflare använder, via `wrangler dev --local` (Miniflare). D1-databasen blir en lokal SQLite-fil under `/data/v3/d1/`.
- **Start:** entrypointen kopierar en skrivskyddad mall till `/srv/klarsprak`, fyller i `PUBLIC_HOST` och Turnstile-nyckeln, kör väntande D1-migreringar och startar servern. Hemligheter skickas till wrangler via en privat env-fil (rättigheter 600) och bakas aldrig in i imagen.
- **Imagen** bygger på `node:24-trixie-slim` (Node LTS på Debian stable), kör som användaren `node` och har en healthcheck mot `/`. Den innehåller bara källkod med platshållare; dina värden fylls i när containern startar.
- **Säkerhet:** svaren får strikt CSP, HSTS och övriga säkerhetshuvuden från appen. Admin-API:t kräver `Authorization: Bearer <ADMIN_TOKEN>`, och tokenet jämförs i konstant tid. Förslag kräver Turnstile och hastighetsbegränsas per hashad IP.
- **Begränsningar:** `wrangler dev` är en utvecklingsserver som kör en process på en maskin. Det räcker gott för en webbplats med normal trafik, men ger inte Cloudflares automatiska skalning eller globala spridning.
- **Felsökning:** `docker compose logs -f`. Hälsostatus syns med `docker compose ps`.

## Changelog

**1.2.1**
- Adminsidan anropar `/admin/api/` direkt, utan ett extra skript som skrev om adresserna. Den gamla adressen `/admin/critical` finns inte längre.

**1.2.0**
- Dokumentationen finns under `/docs`.

**1.1.3**
- Imagen bygger på `node:24-trixie-slim`: Node 24 (LTS) på Debian 13 (stable).

**1.1.2**
- `tools/render.mjs` skriver varje ifylld fil i en loop tills alla byte är skrivna, så att en kort skrivning inte kan lämna en avkortad fil.

**1.1.1**
- `tools/render.mjs` läser och skriver varje fil genom samma filbeskrivare, så att filen inte kan bytas ut mellan kontroll och skrivning.

**1.1.0**
- Inställningar kan ges en gång i `/data/import.env` i stället för i compose-filen. De sparas i `/data/settings.env` och importfilen raderas.
- Imagen byggs från projektets eget repo: `docker build -t klarsprak .`.

**1.0.0**
- Första Docker-imagen, med D1 som SQLite under `/data`. Migreringarna, inklusive de publicerade termerna, körs vid start.
- Rättat: `/admin` hamnade i en omdirigeringsloop mellan `/admin` och `/admin.html`.

## Licens

MIT.
