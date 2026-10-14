# HCV – komplett katalog över emotes med ljud eller animation

Sammanställd 2026-09-07 för Classic Era **1.15.9.69547**. Den installerade WowClassic.exe har samma version som datakällan.

**Urvalsregel:** hörbar röst/ljud eller en synlig animation/ändrad kroppsställning. HUG behålls dessutom som ett uttryckligt RP-undantag enligt användarens önskemål.

- **98 emote-token** har en animationskoppling eller ljudkoppling i klienttabellerna.
- Av dessa finns **96 i UI-källans tokenlista**. TOAST och FAIL redovisas separat som API-kandidater.
- **MOUNTSPECIAL** tillkommer som ett särskilt mountkommando: totalt **99 kandidater**.
- HCV 1.6.3 innehåller **41** av kandidaterna. **58 saknas**, inklusive de tre specialfallen.
- **HUG är ren text** i detta underlag och behålls utöver dessa kandidater som ett RP-undantag: totalt 42 registrerade HCV-alternativ.

Siffran 99 avser token, inte 99 unika ljud eller rörelser. Flera emotes använder samma animation. Slash-alias som /yes för NOD och /lol för LAUGH räknas inte som ytterligare emotes.

Detta är en dataverifierad katalog, inte ett påstående om att samtliga emotes har speltestats. Era tre dagars gemensamma HCV-spel och dungeonreaktioner är separat, verklig speltestning av addonets befintliga beteende.

## Talade repliker och röstkommandon – 22

`HELPME`, `INCOMING`, `CHARGE`, `FLEE`, `ATTACKMYTARGET`, `OOM`, `FOLLOW`, `WAIT`, `HEALME`, `CHEER`, `OPENFIRE`, `RASP`, `HELLO`, `BYE`, `NOD`, `NO`, `THANK`, `WELCOME`, `CONGRATULATE`, `FLIRT`, `JOKE`, `TRAIN`.

Dessa är uttryckligen listade i Blizzards Speech-meny och har ljudkopplingar för Classic-raserna. Alla 22 finns redan i HCV.

## Övriga direkta röstljud och visslingar – 5

| Token | Ljud | HCV 1.6.3 |
|---|---|---|
| BORED | Vissling vid uttråkning | Finns: lång lugn väntan |
| WHISTLE | Vissling | Finns: lång lugn väntan |
| SIGH | Suck | Finns |
| YAWN | Gäspning | Finns |
| MOO | Muande (Tauren) | Finns: Tauren-partyskämt och riktat svar |

MOO är ljudemote för Tauren. För övriga Classic-raser är det ren text och ska därför inte vara ett tillgängligt alternativ.

## Synliga animationer utöver röstkommandona – 71

Här ingår också skratt, gråt, kycklinggest, slängkyss och applåder som kan bära modelljud. Tom direkt ljudkoppling betyder därför inte automatiskt tystnad. Listan lovar bara den belagda rörelsen när modelljud inte är separat verifierat.

| Rörelse | Emote-token |
|---|---|
| Applåd | `APPLAUD`, `CLAP`, `COMMEND`, `GOLFCLAP` |
| Blyg gest | `BASHFUL`, `BLUSH`, `SHY` |
| Bugning | `BOW`, `CURTSEY` |
| Bönfallande gest | `BEG`, `GROVEL`, `MERCY`, `PLEAD`, `SURRENDER` |
| Dans | `DANCE` |
| Frågande gest | `BOGGLE`, `CONFUSED`, `CURIOUS`, `LOST`, `OOPS`, `PONDER`, `PUZZLE`, `SHRUG`, `TALKQ` |
| Gråtanimation | `CRY`, `FAIL`, `MOURN`, `VIOLIN` |
| Honnör | `SALUTE` |
| Knäböjningsgest | `PRAY` |
| Knästående ställning | `KNEEL` |
| Kycklinggest | `CHICKEN`, `TAUNT` |
| Liggande/sovande ställning | `LAYDOWN`, `SLEEP` |
| Nekande huvudgest | `DISAGREE`, `DOUBT` |
| Oförskämd gest | `ANGRY`, `INSULT`, `RUDE` |
| Pekgest | `BLAME`, `BOOP`, `OBJECT`, `POINT` |
| Pratgest | `SING`, `TALK`, `YW` |
| Ropgest | `SHOUT` |
| Rytande gest | `GROWL`, `ROAR` |
| Segergest | `VICTORY` |
| Sittande ställning | `SIT` |
| Skrattanimation | `CACKLE`, `CHUCKLE`, `GIGGLE`, `GLOAT`, `GUFFAW`, `LAUGH`, `ROFL` |
| Slängkyss | `KISS` |
| Spänna musklerna | `FLEX` |
| Stå upp | `STAND` |
| Utropande gest | `GASP`, `TALKEX`, `WHOA` |
| Vinkning | `GREET`, `HAIL`, `WAVE` |
| Ät-/drickgest | `DRINK`, `EAT`, `TOAST` |

## Tre specialfall

- **MOUNTSPECIAL:** synlig mountanimation, separat från EmotesText-tabellen. Bara när en lämplig mount används.
- **TOAST:** kopplad till ät-/drickanimation. Finns i klienttabellen men saknar menytoken; separat prov av API-anrop behövs.
- **FAIL:** kopplad till gråtanimation. Samma krav på separat API-prov. Ingen extra talad ”fail”-replik är belagd här.

## Konsekvenser för HCV:s kommande utökning

- Använd katalogen som tillåtet urval för Voice Lab och kontextuella svar.
- Behåll NOD, WAVE, BOW, SALUTE och andra riktiga gester även när de saknar en talad replik.
- Behåll HUG som uttryckligt RP-undantag. Voice Lab visar det som RP-interaktion och utlovar varken animation eller ljud.
- Märk GASP, ROAR, GROWL och OOPS som animation tills eventuellt ljud är verifierat. SING är en pratgest och utlovar ingen sång.
- Rasspecifika ljud kräver motsvarande ras. Kroppsställningar och mountanimation väljs medvetet, eftersom de påverkar hur karaktären står eller rör sig.
- Ett större urval innebär inte att alla emotes automatiskt ska användas i alla situationer. Varje automatiskt svar behöver fortfarande en passande betydelse.

Rena textemotes som **PAT, SMILE, LOVE, AGREE, APOLOGIZE, BECKON, COWER, CRINGE, SNICKER, THREATEN, BARK och MEOW** är uteslutna. HUG är det uttryckliga RP-undantaget. Att texten beskriver en handling eller ett ljud betyder inte att modellen utför den eller att ett ljud spelas.

## Fullständig jämförelse med HCV 1.6.3

| Token | Finns i HCV | Rörelse | Ljudunderlag | Anmärkning |
|---|---|---|---|---|
| ANGRY | Nej | Oförskämd gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| APPLAUD | Ja | Applåd | Ej separat ljudkoppling; animation kan bära ljud |  |
| ATTACKMYTARGET | Ja | Rytande gest | Talad replik/röstkommando |  |
| BASHFUL | Nej | Blyg gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BEG | Nej | Bönfallande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BLAME | Nej | Pekgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BLUSH | Nej | Blyg gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BOGGLE | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BOOP | Nej | Pekgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| BORED | Ja | Ingen animation | Vissling vid uttråkning | Lång lugn väntan |
| BOW | Ja | Bugning | Ej separat ljudkoppling; animation kan bära ljud |  |
| BYE | Ja | Vinkning | Talad replik/röstkommando |  |
| CACKLE | Ja | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| CHARGE | Ja | Pekgest | Talad replik/röstkommando |  |
| CHEER | Ja | Segergest | Talad replik/röstkommando |  |
| CHICKEN | Nej | Kycklinggest | Ej separat ljudkoppling; animation kan bära ljud |  |
| CHUCKLE | Nej | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| CLAP | Nej | Applåd | Ej separat ljudkoppling; animation kan bära ljud |  |
| COMMEND | Nej | Applåd | Ej separat ljudkoppling; animation kan bära ljud |  |
| CONFUSED | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| CONGRATULATE | Ja | Utropande gest | Talad replik/röstkommando |  |
| CRY | Ja | Gråtanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| CURIOUS | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| CURTSEY | Nej | Bugning | Ej separat ljudkoppling; animation kan bära ljud |  |
| DANCE | Nej | Dans | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| DISAGREE | Nej | Nekande huvudgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| DOUBT | Nej | Nekande huvudgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| DRINK | Nej | Ät-/drickgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| EAT | Nej | Ät-/drickgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| FAIL | Nej | Gråtanimation | Ej separat ljudkoppling; animation kan bära ljud | Finns i klienttabellen men saknar registrerat menytoken; separat API-prov behövs. |
| FLEE | Ja | Ropgest | Talad replik/röstkommando |  |
| FLEX | Nej | Spänna musklerna | Ej separat ljudkoppling; animation kan bära ljud |  |
| FLIRT | Ja | Blyg gest | Talad replik/röstkommando |  |
| FOLLOW | Ja | Pratgest | Talad replik/röstkommando |  |
| GASP | Ja | Utropande gest | Ej separat ljudkoppling; animation kan bära ljud | Animation är belagd; talat/extra ljud är inte belagt av denna ljudtabell. |
| GIGGLE | Ja | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| GLOAT | Nej | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| GOLFCLAP | Nej | Applåd | Ej separat ljudkoppling; animation kan bära ljud |  |
| GREET | Nej | Vinkning | Ej separat ljudkoppling; animation kan bära ljud |  |
| GROVEL | Nej | Bönfallande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| GROWL | Nej | Rytande gest | Ej separat ljudkoppling; animation kan bära ljud | Animation är belagd; talat/extra ljud är inte belagt av denna ljudtabell. |
| GUFFAW | Ja | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| HAIL | Nej | Vinkning | Ej separat ljudkoppling; animation kan bära ljud |  |
| HEALME | Ja | Pratgest | Talad replik/röstkommando |  |
| HELLO | Ja | Vinkning | Talad replik/röstkommando |  |
| HELPME | Ja | Ropgest | Talad replik/röstkommando |  |
| INCOMING | Ja | Ropgest | Talad replik/röstkommando |  |
| INSULT | Nej | Oförskämd gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| JOKE | Ja | Pratgest | Talad replik/röstkommando |  |
| KISS | Ja | Slängkyss | Ej separat ljudkoppling; animation kan bära ljud |  |
| KNEEL | Nej | Knästående ställning | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| LAUGH | Ja | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| LAYDOWN | Nej | Liggande/sovande ställning | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| LOST | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| MERCY | Nej | Bönfallande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| MOO | Ja | Ingen animation | Muande (Tauren) | Endast Tauren; partyskämt och riktat svar |
| MOUNTSPECIAL | Nej | Mountens specialrörelse | Särskild mountanimation | Separat klientkommando; kräver lämplig mount. Rörelse och eventuellt ljud beror på mounten. |
| MOURN | Ja | Gråtanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| NO | Ja | Nekande huvudgest | Talad replik/röstkommando |  |
| NOD | Ja | Nickning | Talad replik/röstkommando |  |
| OBJECT | Nej | Pekgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| OOM | Ja | Pratgest | Talad replik/röstkommando |  |
| OOPS | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud | Animation är belagd; talat/extra ljud är inte belagt av denna ljudtabell. |
| OPENFIRE | Ja | Pekgest | Talad replik/röstkommando |  |
| PLEAD | Nej | Bönfallande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| POINT | Nej | Pekgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| PONDER | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| PRAY | Nej | Knäböjningsgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| PUZZLE | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| RASP | Ja | Oförskämd gest | Talad replik/röstkommando |  |
| ROAR | Ja | Rytande gest | Ej separat ljudkoppling; animation kan bära ljud | Animation är belagd; talat/extra ljud är inte belagt av denna ljudtabell. |
| ROFL | Nej | Skrattanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| RUDE | Nej | Oförskämd gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| SALUTE | Ja | Honnör | Ej separat ljudkoppling; animation kan bära ljud |  |
| SHOUT | Nej | Ropgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| SHRUG | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| SHY | Nej | Blyg gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| SIGH | Ja | Ingen animation | Suck |  |
| SING | Nej | Pratgest | Ej separat ljudkoppling; animation kan bära ljud | Pratanimation, ingen verifierad sjungen replik. |
| SIT | Nej | Sittande ställning | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| SLEEP | Nej | Liggande/sovande ställning | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| STAND | Nej | Stå upp | Ej separat ljudkoppling; animation kan bära ljud | Ändrar ställning eller startar en ihållande animation; eget manuellt val. |
| SURRENDER | Nej | Bönfallande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| TALK | Nej | Pratgest | Ej separat ljudkoppling; animation kan bära ljud |  |
| TALKEX | Nej | Utropande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| TALKQ | Nej | Frågande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| TAUNT | Nej | Kycklinggest | Ej separat ljudkoppling; animation kan bära ljud |  |
| THANK | Ja | Pratgest | Talad replik/röstkommando |  |
| TOAST | Nej | Ät-/drickgest | Ej separat ljudkoppling; animation kan bära ljud | Finns i klienttabellen men saknar registrerat menytoken; separat API-prov behövs. |
| TRAIN | Ja | Tåggest | Talad replik/röstkommando |  |
| VICTORY | Ja | Segergest | Ej separat ljudkoppling; animation kan bära ljud |  |
| VIOLIN | Nej | Gråtanimation | Ej separat ljudkoppling; animation kan bära ljud |  |
| WAIT | Ja | Pratgest | Talad replik/röstkommando |  |
| WAVE | Ja | Vinkning | Ej separat ljudkoppling; animation kan bära ljud |  |
| WELCOME | Ja | Pratgest | Talad replik/röstkommando |  |
| WHISTLE | Ja | Ingen animation | Vissling | Lång lugn väntan |
| WHOA | Nej | Utropande gest | Ej separat ljudkoppling; animation kan bära ljud |  |
| YAWN | Ja | Ingen animation | Gäspning |  |
| YW | Nej | Pratgest | Ej separat ljudkoppling; animation kan bära ljud |  |

## Källor och metod

- [Classic Era-datans version och revision](https://github.com/Vladinator/wow-dbc-archive/commit/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae) – export av Blizzard-tabeller, klient 1.15.9.69547.
- [EmotesText](https://github.com/Vladinator/wow-dbc-archive/blob/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae/emotestext.csv) – 255 token och deras EmoteID.
- [Emotes](https://github.com/Vladinator/wow-dbc-archive/blob/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae/emotes.csv) – animation och ställningsbeteende.
- [EmotesTextSound](https://github.com/Vladinator/wow-dbc-archive/blob/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae/emotestextsound.csv) – 418 ljudkopplingar för Classic-raserna, inklusive två för Taurens MOO.
- [Blizzards Classic-emote- och Speech-lista](https://github.com/Gethe/wow-ui-source/blob/3e8c5573ef8b5d4b57053e6f7d0c6f4dd072210f/Interface/AddOns/Blizzard_ChatFrameBase/Classic/ChatEmoteConstants.lua).
- Lokal jämförelse: HCVoice.lua, OFFICIAL_SPEECH och VOCAL_REACTIONS i version 1.6.3.

Urvalet görs genom kopplingen EmotesText.ID → EmotesTextSound.EmotesTextID och EmotesText.EmoteID → Emotes.ID. EmoteID > 0 räknas som rörelse/ställning. EmoteID 0 kräver en SoundID > 0 för någon av Classic-raserna 1–8. STAND har ett ställningsbeteende trots AnimID 0. MOUNTSPECIAL finns separat i UI-källan.

Kontroller: 98 unika datatoken, 96 registrerade UI-token, alla 22 Speech-token inkluderade, 41 träffar mot HCV 1.6.3 och HUG som enda uttryckliga RP-undantag utanför ljud-/animationsurvalet. Katalogen dokumenterar urvalet; runtime-ändringarna i 1.6.2 och 1.6.3 beskrivs i IMPLEMENTATION_HISTORY.md.
