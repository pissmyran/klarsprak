# Översikt

```text
Webbläsare
    |
    v
src/index.js     värdnamn, adminrouting, SEO och säkerhetshuvuden
    |
    v
src/worker.js ──> D1 (DB)    publicerade termer, förslag och granskning
    |
    +──> ASSETS (public/)    sidorna, skripten och stilarna
```

| Ämne | Sida |
| --- | --- |
| Routing, publicering, granskning, säkerhet och PWA | [Arkitektur](architecture.md) |
| Lokal utveckling, migreringar, driftsättning, kontroller och felsökning | [Drift](operations.md) |

## De tre flödena

- **Läsning:** sidan hämtar de publicerade termerna från `GET /api/terms`. D1 är den enda källan; sidan visar bara det API:t svarar.
- **Förslag:** en besökare skickar ett förslag med `POST /api/submit`. Turnstile skyddar formuläret, och förslaget hamnar i granskningskön utan att publiceras.
- **Granskning:** administratören läser kön på `/admin` och redigerar, godkänner, publicerar eller arkiverar med uttryckliga steg.

## Innan du ändrar något

- **Routes, värdnamn eller SEO:** läs [Arkitektur](architecture.md) och [Drift](operations.md).
- **D1-schemat eller publiceringen:** skriv en ny migrering och uppdatera [Arkitektur](architecture.md).
- **Förslag, granskning eller admin:** läs [Arkitektur](architecture.md) och kontrollera säkerhetsgränserna efteråt.
