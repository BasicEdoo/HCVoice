# HCVoice – bossreaktioner för Classic Era Hardcore

Datum: 2026-09-15. Status: **implementerat i 1.7.0, med kvarvarande speltest**.

## Aktuellt resultat

Alla 230 katalogkort har individuella emoteval, motiveringar, NPC-ID:n och automatiska regler. Ingen boss-popup. [Den genererade listan beskriver exakt körbart innehåll](BOSS_REACTIONS_1.7.0.md); [genomföranderapporten beskriver tester och begränsningar](IMPLEMENTATION_HISTORY.md). Registret ligger tillsammans med motorn i `HCVoice_Bosses.lua`, innehållet i `Bosses/Content.lua`. Den enklare filindelningen ersätter planens förslag om en separat fil per dungeon.

181 simulerade beteendetester och syntaxkontroll av åtta runtimefiler passerar. Många mekaniker hanteras genom säkra start-/slutvillkor; sju utvalda signaler har dessutom egna fasreaktioner. Fristående miljöscener i katalogens idéavsnitt är inte aktiva bossregler. Hörbar röst, animation, händelseordning och tempo återstår att verifiera i spelklienten.

**Nedan bevaras den ursprungliga designplanen som bakgrund. Framtidsform och dåvarande status avser planeringstillfället före implementationen; de aktuella dokumenten ovan gäller för 1.7.0.**

## 1. Det vi bygger

Våra karaktärer ska reagera mer på det som faktiskt händer i dungeons, med **befintliga Blizzard-röster och synliga animationer**. Varje boss ska få ett genomtänkt urval av reaktioner som passar dess identitet, historia och händelser i Classic Era Hardcore.

Användarens avgränsning: inga egna repliker, ingen egen dialog, inga nya inspelningar eller TTS. Enbart röst/ljud och animationer som redan finns i spelet. Blizzards ordinarie emoterad kan följa med en standardemote; vi skriver eller skickar ingen egen chattprosa.

Planens innehåll är alla vanliga Classic Era-dungeons, inklusive deras vingar, sällsynta bossar och särskilda questmöten. UBRS ingår och behöver provas även med sin större gruppstorlek. Raids och världsbossar blir ett separat innehållspaket om vi tar dem senare. Inga möten eller mekaniker från SoD, TBC, Wrath, Cataclysm, Retail eller privata servervarianter förs in.

**[Bosslistan finns i BOSS_RESEARCH.md](BOSS_RESEARCH.md).** Alla listade kort börjar som inventerade; deras individuella reaktioner återstår att utforma och prova.

## 2. Hur det ska kännas

- Bossens personlighet styr valet: hån, trots, förvåning, respekt, rädsla eller lättnad.
- Händelsen styr tidpunkten. En unik mekanik ger ett bättre tillfälle än en slumpmässig timer.
- En boss behöver inte få en reaktion i varje fas. Ett enda välvalt ögonblick kan räcka.
- Variationen ska behålla betydelsen: två passande segergester kan varieras; sorg ska inte slumpas till skratt.
- Lore utan säkert stöd lämnas öppen. Vi hittar inte på släktskap, motiv eller kunskap som karaktären inte rimligen har.
- Bossarna får inte alla samma sekvens av hån, förvåning och jubel. Kortet ska förklara vad som gör just det mötet speciellt.

## 3. Struktur: dungeon → möte → boss → reaktion

| Nivå | Innehåll |
|---|---|
| Innehållspaket | Classic Era Hardcore; tydligt versionsavgränsat |
| Dungeon | Identitet, tema och gemensamma miljöhändelser |
| Vinge/rutt | Exempelvis SM Library eller Dire Maul North |
| Möte | En sammanhängande strid eller ett event, även med flera NPC:er |
| Bosskort | Bossens identitet, loreunderlag, särdrag och passande emotes |
| Reaktion | Observerad händelse, mottagare, emote, prioritet och giltighetstid |

Ett möte kan innehålla flera bosskort. Sneed och hans shredder, Mograine/Whitemane och The Seven behöver gemensam kontroll av när hela mötet är avslutat. Vingar och rutter i katalogen är redaktionella avsnitt, inte ett påstående om separata instance-ID:n.

### Mall för ett bosskort

| Fält | Vad vi fyller i |
|---|---|
| Stabil nyckel | Egen unik nyckel som inte beror på klientens språk |
| Identitet | Engelskt NPC-namn, verifierade NPC-ID:n och dungeonidentitet |
| Mötesgrupp | Andra bossar, former eller följeslagare i samma möte |
| Typ | Vanlig boss, rare, questboss, event, följeslagare eller villkorad NPC |
| Loreunderlag | Kort faktanotering och källa som gäller Era |
| Personlighet | Exempelvis arrogant, korrumperad, tragisk eller djurisk; tolkning märks som tolkning |
| Unikt tillfälle | Vad denna boss gör som motiverar en särskild reaktion |
| Utlösare | Observerbar händelse; ID och signal lämnas öppna tills de kontrollerats |
| Emote | En befintlig token; högst ett litet antal likvärdiga alternativ |
| Uttryck | Talad standardröst, annat ljud eller synlig animation |
| Mottagare | Bossen, en verifierad medspelare eller ingen riktad mottagare |
| Villkor | Rätt möte, levande spelare, korrekt fas och fortfarande relevant situation |
| Avbryt | Ny fara, dödsfall, fel mål, ändrad fas, avstängning eller passerat tillfälle |
| Upprepning | En gång per definierat tillfälle och gemensam paus mellan reaktioner |
| Slutvillkor | Hur hela mötets seger, reset eller avbrott faktiskt bekräftas |
| Bevis/status | Lore, detektering, simulering och speltest redovisas var för sig |

NPC-ID:n, spell-ID:n och klienthändelser fylls inte med gissningar. Namnlistan är en innehållsinventering, inte färdig detekteringsdata.

## 4. Tillfällen som ett bosskort kan använda

| Tillfälle | Avsikt | Grundregel |
|---|---|---|
| Bossen uppmärksammas | Trots, hån, respekt eller förvåning | Bekräftad identitet och avsiktligt sammanhang; inte bara för att en NPC finns någonstans i instansen |
| Striden börjar | Reaktion på det faktiska mötet | Bekräftad strid med rätt boss; inget automatiskt stridskommando som uppmanar till pull |
| Särskild händelse | Reaktion på bossens signatur | Verkligen observerad fas, förmåga, form eller förstärkning |
| Fara för spelaren | Rädsla eller rop på hjälp | Återanvänd faktisk fara; bossens närvaro ensam är inte ett nödläge |
| Hela mötet är vunnet | Seger, lättnad eller respekt | Bekräftat slut och utrymme efter striden |
| Någon i gruppen dör | Sorg och återhållsamhet | Tar bort planerat hån och jubel; bara överlevande kan reagera |
| Striden avbryts | Tystnad eller senare lättnad | Tappat mål, despawn eller tappad strid bevisar inte seger |

Låg boss-HP ska inte ge seger i förskott. Hardcore-flykten ska inte utlösa skämt om en ny chans efter döden.

## 5. Palett av befintliga emotes

Underlag: installerad HCVoice 1.6.6, dess registrerade emotes och [den lokala emotekatalogen](EMOTE_REFERENCE.md). Katalogens klientdata är daterad 2026-09-07; varje nytt val behöver fortfarande ett verkligt speltest.

| Avsikt | Kandidater som redan är registrerade i HCV | Begränsning |
|---|---|---|
| Hån/trots | `RASP`, `LAUGH`, `ROAR` | Särskild bossmotivering; ROAR behandlas som animation tills ljud är belagt |
| Förvåning | `GASP` | Synlig gest; vi lovar inget särskilt röstljud |
| Verklig fara | `HELPME`, `HEALME`, `FLEE`, `INCOMING` | Befintliga faroregler har företräde; inga dubbla varningar |
| Lättnad | `SIGH` | Efter att den egna faran verkligen har passerat |
| Seger | `CHEER`, `VICTORY`, `APPLAUD` | Hela mötet klart och ingen aktuell sorg |
| Respekt | `BOW`, `SALUTE` | Ska passa personen och utfallet, inte väljas generiskt |
| Sorg | `MOURN`, `CRY` | Verifierat dödsfall; inte för försvunnet mål eller dismissat pet |

`TAUNT`, `RUDE`, `POINT` och liknande är ytterligare animationskandidater i den lokala katalogen, men de är inte registrerade i nuvarande HCV. Vi kan bedöma dem senare när ett konkret bosskort behöver dem. `TAUNT` avser då en kosmetisk emote, inte en klassförmåga.

Rena textemotes ingår inte i detta bosspaket. Ras, kön, form och klientens faktiska uppspelning måste kontrolleras för de val vi använder. En standardröst kan variera; den är inte en egen bossreplik.

## 6. Exempel på specialisering – förslag, inte aktiva regler

| Möte | Specifikt tillfälle | Förslag med befintliga emotes |
|---|---|---|
| Sneed's Shredder / Sneed | Piloten fortsätter striden när maskinen faller | `GASP` vid bekräftad övergång; eventuell `CHEER` först efter båda delarna |
| Mr. Smite | Stomp och vapenbyte | En förvånad gest i ett giltigt ögonblick efter stun; ingen kö av reaktioner för varje vapenbyte |
| Edwin VanCleef | Ytterligare Blackguards ansluter | Befintlig `INCOMING` endast om verklig extra fara bekräftas; samma varning får inte spelas två gånger |
| Mograine / Whitemane | Whitemane återupplivar Mograine | `GASP` vid den bekräftade återkomsten; segern väntar på hela mötet |
| Herod | Hans uppvisning och stridens efterspel | Bedöm `RASP` som bossriktat trots; eventuell seger först när även efterföljande hot är avslutade |
| Pusillin | Jakten går över i en fientlig konfrontation | Bedöm ett kort `RASP` först när rätt steg faktiskt nåtts; ingen påhittad dialog med honom |
| King Gordok / Cho'Rush | Vanlig seger eller ett avslutat tribute-förlopp | Separata slutvillkor; en överlevande vänlig NPC räknas inte som kvarvarande fiende |

Händelseunderlag: [Deadmines](https://www.wowhead.com/classic/guide/deadmines-dungeon-strategy-wow-classic), [Scarlet Monastery](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic), [Dire Maul East](https://www.wowhead.com/classic/guide/dire-maul-east-dungeon-strategy-wow-classic) och [Dire Maul North](https://www.wowhead.com/classic/guide/dire-maul-north-dungeon-strategy-wow-classic). Emotevalen är våra designförslag. Exakt teknisk detektering är ännu inte verifierad.

## 7. Naturligt tempo

Föreslagna startvärden, att kalibrera i spelet:

- Högst en öppningsreaktion och en avslutningsreaktion per möte.
- Högst en reaktion per utvald signaturhändelse; normalt högst två sådana under en bossstrid.
- Minst 12 sekunder mellan kosmetiska bossreaktioner. Befintliga akuta varningar behåller sina egna regler och prioritet.
- Ett stridstillfälle förfaller snabbt, preliminärt efter 3 sekunder. Inga gamla fasreaktioner spelas när spelaren åter kan agera långt senare.
- Efterseger väntar tills gruppens relevanta strid är över och avbryts av ny fara.
- Casting, channeling, kontrollförlust och andra lägen där en kosmetisk gest stör eller inte kan visas gör att tillfället hoppas över. Ingen automatisk handling ändrar target, rörelse, förmågor eller petorder.
- Bossens egna rop ska få utrymme när de kan observeras. Vi ska inte lägga en hel kör ovanpå dem.
- Med flera HCV-spelare samordnas kosmetiska öppningar och signaturögonblick till en deltagare per tillfälle. Egna nödlägen förblir individuella.

Tiderna är förslag, inte påståenden om befintligt beteende eller garanterad uppspelning.

## 8. Koppling till nuvarande HCV

Kontrollerat i installerade filer 2026-09-15:

- `HCVoice.lua` innehåller emoteregistret, befintliga scenarier, `hardVictory` och själva emoteanropet.
- `HCVoice_Director.lua` sköter kö, prioritet, aktualitet, sorg och beslutshistorik. Nuvarande allmänna stridsspärr behöver en uttrycklig, begränsad väg för eventuella kosmetiska bossreaktioner under strid.
- `HCVoice_Social.lua` hanterar sociala dungeonsvar; bossreaktioner behöver egna regler och ska inte maskeras som ett svar från en spelare.
- `HCVoice_LivingWorld.lua` samordnar redan gruppscener. Ett nytt bosstillfälle ska inte dubbleras med befintlig `hardVictory` eller med en annan klients observation.
- `HCVoice_GUI.lua` kan senare få en samlad inställning för bossreaktioner, med fördjupning per dungeon.

Föreslagen framtida filindelning:

```text
HCVoice_Bosses.lua             identifiering och mötestillstånd
Bosses/Registry.lua            gemensam datamall och uppslag
Bosses/Dungeons/<dungeon>.lua  innehåll per dungeon, med vingar i samma fil
```

Detta är en tänkt indelning. Inga nya Lua-filer laddas och ingen TOC/version ändras i denna planeringsomgång. Befintliga API:er och eventuell ny detektering ska kontrolleras mot Era innan implementation; detta dokument specificerar inget nytt API-kontrakt.

## 9. Arbetsordning och status

Status per bosskort: **Inventerad → Lore och möte granskat → Emotes valda → Detektering verifierad → Implementerad → Speltestad**.

1. **Inventering:** alla dungeons och deras boss-/eventkort läggs i katalogen.
2. **Litet pilotpaket:** Deadmines, Wailing Caverns och Shadowfang Keep. Det ger olika teman, flerfasstrid och ett eskortevent. Alla andra dungeons behåller sin plats i listan.
3. **Innehåll:** välj ett fåtal specifika tillfällen per boss och kontrollera Era-lore samt standardemotens verkliga uttryck.
4. **Teknik:** inför identitet och mötestillstånd i befintlig director; bevara prioritet, avstängning och egna inställningar.
5. **Prov:** simulera relevanta sekvenser och spela piloten i Classic Era Hardcore. Justera tempo och semantik.
6. **Utbyggnad:** ta resterande katalogavsnitt i grupper. Komplexa möten som BRD, tribute, Scholomance och UBRS får egna genomgångar.

### När ett bosskort är klart

- Era-identitet, relevanta NPC:er och vald händelse är verifierade.
- Kortet har en konkret anledning till varje emote och en korrekt mottagare.
- Bara standardröster/ljud och synliga animationer används.
- Flerfasstrid, reset, despawn och kvarvarande fiender ger inte falsk seger.
- Hot, sorg, manuella emotes och avstängning hanteras av samma prioritering som resten av HCV.
- Simulerade sekvenser täcker fel mål, fördröjd händelse, dubbla observationer, dödsfall, reload och zon-/gruppbyte där det är relevant.
- Ett verkligt speltest bekräftar uppspelning, animation och tajming för aktuella uttryck. Ett lyckat API-anrop räcker inte som ljudbevis.

## 10. Resultat av denna planeringsomgång

Två dokument: denna struktur och den tillhörande bosskatalogen. Nuvarande addonbeteende har inte ändrats. Lore- och spelteststatus ska föras framåt per kort; inventerad betyder inte att alla bossar redan har färdiga reaktioner.
