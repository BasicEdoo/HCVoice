# Verifiering – HCVoice 1.7.0

Kontrollerat 2026-09-15. Förberedelsen är lokal; inget CurseForge-projekt har skapats och ingen fil har laddats upp.

## Paket

| Kontroll | Resultat |
|---|---|
| Offentligt upphovsnamn | Edòó |
| Licens | All Rights Reserved |
| Fil | HCVoice-1.7.0.zip |
| Storlek | 107611 byte |
| Version / schema | 1.7.0 / 170 |
| Klientmål | Classic Era 1.15.9, Interface 11509 |
| Installerad klient | 1.15.9.69722 |
| ZIP-struktur | En rotmapp, `HCVoice/`, med `HCVoice/HCVoice.toc` |
| Innehåll | 14 filer, varav åtta runtime-Lua-filer |
| Filkontroll | ZIP-integritet och varje fils innehåll jämfört byte för byte mot källan |
| Runtimeändringar | Inga; de åtta runtimefilerna matchar startlägets hashvärden |
| Lua 5.1 | Alla åtta runtimefiler passerade syntaxkontrollen |
| Beteendetester | 181 av 181 passerade mot filer uppackade ur den färdiga ZIP-filen |

SHA256:

```text
4e03b866ae455344ed28c2fa0db120739655ae381f7c06e57c6c1b4250142827
```

## Granskning av offentlig information

- TOC, README, copyright och projektbeskrivning använder **Edòó**, inklusive exakt stavning och accenter. Manifestet använder samma namn.
- Tidigare personnamn har ersatts även i lokala testexempel. Tester och testloggar ingår inte i ZIP-filen.
- De 14 paketfilerna, projekttexterna och manifestet har sökts igenom efter tidigare personnamn, användarkataloger och maskinsökvägar, e-postadresser, BattleTags, sparade spelar-GUID:er och vanliga hemlighetsformat. Inga träffar hittades i det färdiga materialet.
- Länkar i texterna går till offentliga CurseForge-sidor och Wowhead-guider. Inga privata profil-, kontakt- eller repositorylänkar finns där.
- ZIP-filen har inga kommentarer eller extra metadatafält. Filtiderna är fasta och avslöjar inte lokala arbets- eller speltider.
- Projektikonen är en PNG på **1254 x 1254** pixlar. Dess C2PA-metadata anger bildgenereringens ursprung. Ingen träff på personnamn, e-postadress eller lokal sökväg hittades i bildmetadata. Ingen spelarbild eller skärmbild ingår.

Detta gäller det granskade lokala materialet. CurseForge-kontots offentliga profil har inte inspekterats. Kontrollera visningsnamn, profiltext och länkar innan uppladdning. Nya skärmbilder och loggar behöver granskas separat.

## Kvar i spelet

Följ [SMOKE_TEST.md](../../release/SMOKE_TEST.md). Ljud, animation, UI-layout, faktisk tajming och bossarnas verkliga signaler har inte testats live här. Menyerna är huvudsakligen engelska, men svarskortets knappar är svenska; det är beskrivet i projekttexten.

Versionsanteckningarna och projektbeskrivningen anger dessa begränsningar. Välj Release efter godkänd grundkontroll eller Beta för tidig provning enligt publiceringsguiden.
