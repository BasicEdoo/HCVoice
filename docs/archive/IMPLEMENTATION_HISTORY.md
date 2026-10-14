# HCVoice 1.7.0 – genomförande och verifiering

Uppdaterat 2026-09-15 i den installerade addonmappen.

## Automatiska bossreaktioner i 1.7.0

- **230 individuellt utformade möteskort i 26 dungeon-/vingavsnitt**, med NPC-ID, öppningsreaktion, avslutning och RP-motivering. [Hela listan med aktiva regler](BOSS_REACTIONS_1.7.0.md) genereras från samma innehåll som spelet laddar. 230 avser möteskort, inte unika röstfiler eller exakt lika många NPC:er.
- **Automatiskt, utan boss-popups.** Bara befintliga Blizzard-röster/ljud och synliga animationer. Inga egna repliker, ljudfiler, TTS eller vanlig chatttransport. Blizzards standardemoterad kan fortfarande synas. Kör `/reload`; inställningarna finns i `/hcv` → **Reactions → Boss reactions - Classic Era Hardcore**.
- Paketet kräver Classic Era och `C_GameRules.IsHardcoreActive()`. Instans/map-ID, NPC-ID från GUID och spelarens/gruppens verkliga deltagande styr detektering. Bara katalogens dungeonkartor används; Maraudons utomhuskhaner har ett uttryckligt undantag. UBRS kan köras som raidgrupp på dungeonkartan; raidinstanser ingår inte.
- Sneed, Halycon/Gizrul, Gyth/Rend, Dreadsteed/Hel'nurath och Dathrohan/Balnazzar har särskilda NPC-övergångar. Smite använder verkligt borttagen Stomp-aura; Whitemanes resurrection nollställer Mograines tidigare dödsbevis. Moira och Cho'Rush behöver inte dö. Herod och Ramstein väntar längre efter striden. För övriga grupperade kort krävs observerad död för alla listade medlemmar.
- Öppning kräver rätt fientligt target. Utvalda kort kan reagera efter 1,5 sekunders avsiktligt målval. Högst en öppning, två definierade signaturtillfällen och en avslutning per möte; minst tolv sekunder mellan kosmetiska reaktioner. Stridstillfällen förfaller efter tre sekunder. Seger väntar minst fyra sekunder utan gruppstrid och har tolv sekunders kötid; Herod/Ramstein väntar minst tolv sekunder innan köning.
- Akut fara, sorg, casting/channeling, kontrollförlust, nytt target, ny strid, zonbyte, verkligt gruppbyte och avstängning gör gamla tillfällen ogiltiga. Ett INCOMING vid pull kan därför ersätta bossöppningen. Petorder, förmågor, rörelse och target ändras inte. En försvunnen NPC eller tappad strid är aldrig ett segerbevis.
- Samma version samordnar deltagare via `HCVB1` i dold addontrafik. Endast verifierade gruppmedlemmar och kända kort/signaler accepteras. Paketen kan bara undertrycka egna observerade reaktioner. Samordningen är beroende av meddelandeleverans; den är inte en garanti mot samtidiga röster vid nätverksfördröjning. Generisk `hardVictory` och Living World-seger undertrycks för dessa aktiva bossmöten.
- Nytt: `HCVoice_Bosses.lua` (register/motor) och `Bosses/Content.lua` (innehåll). TOC laddar åtta Lua-filer. Version 1.7.0/schema 170. Huvudval och 26 dungeonval finns i menyn och följer export/import. Äldre egna val bevaras; Quiet stänger av nytillskottet.

### Verifiering och gränser

- Lua 5.1-syntaxkontroll passerar för samtliga åtta runtimefiler. **181 beteendetester passerar**, varav 36 nya bossfall. Tester laddar den faktiska TOC-ordningen och kör mot den riktiga director-koden med simulerade WoW-API:er.
- Testerna omfattar identitet/version/karta, deltagande och pets, riktat target, cooldown/avbrott, flerfasmöten, bekräftad död, sorg, kontrollförlust, faroprioritet med normala inställningar, gruppsynk, ogiltiga paket, reload/zonbyte, sparade val och varje korts slutvillkor. Den genererade listan jämför dessutom katalogens samtliga 230 nycklar med runtimeinnehållet.
- Baslinjens pettester hade för kort väntetid för directorfördröjningen. Tre väntetider har justerats: direkt petorder, fördröjd petbekräftelse och akut fara framför petljud. Pet-/farokoden eller dess timing ändrades inte.
- NPC-ID:n hämtades från installerade `Questie/Database/Classic/classicNpcDB.lua`; samtliga katalogidentiteter fick entydiga träffar. Detta är ett utvecklingsunderlag, inget runtimeberoende. Dungeon-/möteskällor är länkade i [bosskatalogen](BOSS_RESEARCH.md). Emoteval och motiveringar är designbeslut, inte påhittade bossrepliker.
- Hardcore-API kontrollerat mot [Blizzards Classic Era GameRules-kod](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_APIDocumentationGenerated/GameRulesDocumentation.lua). GUID- och instansuppslag granskades via Context7. Signaturunderlag: [Smite Stomp 6432](https://www.wowhead.com/classic/spell=6432/smite-stomp) och [Scarlet Monastery](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic).
- **Inte verifierat i körande WoW:** faktisk hörbarhet, animation i olika former/raser, menyernas rendering, exakt ordning på bossarnas klienthändelser och tempo i varje dungeon. Ett genomfört emoteanrop bevisar inte hörbart ljud. De tomma rutorna i katalogen avser därför kvarvarande speltest, inte saknad implementation.

Spelkontroll: `/reload`, kontrollera 1.7.0 och aktiverat bossval. Prova först ett tydligt bossmål före strid och sedan hela mötet. Kontrollera att vanliga faror får företräde, att ingen bossruta visas och att seger väntar tills gruppen är ur strid. Prova flerfasmöten och samordning med ytterligare en 1.7.0-klient. Diagnostiksidan visar vilket bosskort och tillfälle som försöktes.

Återställningskopia före implementation: `local-artifacts/HCVoice-before-bosses-20260915-145421`.

## Kompakt svarsruta i 1.6.6

- Svarsrutan är 320x140 UI-enheter i stället för 430x202, cirka 48 procent mindre yta. Med högst två svar krymper den till 320x110. Standardplacering vid högerkanten; egen sparad placering behålls.
- Stor varumärkesrubrik, upprepad instruktion och dubblerad stängknapp är borttagna. Neutral kant, diskret bakgrund och MEDIUM-lager. Texten behåller full opacitet och alla svar är direkt klickbara med 26 enheter höga knappar.
- Avsändare och meddelande begränsas till varsin rad. Hela texten finns i tooltip över kortets textyta. Ignorera spelaren är en separat, nedtonad textknapp. Kryss, Escape, dragning och befintlig automatisk stängning finns kvar.
- Ingen ändring av svarens logik, dungeonregeln eller pet-kommandon. Schema 165 behålls. Utseende och läsbarhet behöver kontrolleras i spelklienten efter /reload; simulerade tester kan inte verifiera rendering.
- Aktuell körning: syntaxkontroll för sex Lua-filer och 126 beteendetester passerar. Sviten stannar sedan på `a pet attack command produces one prompt CHARGE without issuing commands`. Samma fel reproduceras med den orörda säkerhetskopian av 1.6.5; hela sviten är alltså inte grön i denna körning. Tidigare resultat längre ned avser tidigare körningar.

Återställningskopia: `local-artifacts/before`.

## Pet-kommandon i 1.6.5

- `petAttack`: spelar CHARGE efter ett eget attackkommando som bekräftats av aktiv pet-attack mot rätt levande fiende. Högst en gång per strid och med åtta sekunders cooldown. Petens automatiska självförsvar räknas inte som ett kommando från spelaren.
- `petRecall`: spelar WHISTLE när Follow kallar tillbaka ett attackerande pet eller ett pet på Stay. Redan följande pet och vanliga automatiska återvändanden efter en död fiende ger ingen vissling. Åtta sekunders cooldown.
- Båda scenarierna är automatiska under Reactions > Combat. De fungerar också i strid och dungeons och skapar inga svarsrutor. Totalt finns nu 35 scenarier. Schema 165 fyller på nya val utan att skriva över befintliga inställningar; Quiet lämnar dem avstängda.
- Koden observerar `PetAttack`, `PetFollow` och `CastPetAction` med säkra efterhandskopplingar via `hooksecurefunc`. Den utfärdar inga pet-kommandon och ändrar inga knappar, makron eller skyddade attribut. Uppspelning kräver att petens kommandostatus bekräftas inom en sekund; gammalt ljud förfaller efter två sekunder i kön.
- Petens identitet, hälsa, attackmål och Follow-status kontrolleras igen före ljudet. Ett nytt kommando kan avbryta föregående ljud. Upprepningar sammanfogas, CHARGE återaktiveras först efter avslutad strid och akuta varningar behåller högre prioritet. Visslingen vid återkallelse behandlas som ett kommando även när skämt tillfälligt är pausade.
- Baslinjen passerade 126 tester. Samtliga 145 tester och syntaxkontrollen för sex Lua-filer passerar efter ändringen. De 19 nya testerna täcker kommandon, flyttade knappar, dubbla hooks, mouseover-mål, fördröjd eller utebliven bekräftelse, självförsvar, återkallelse, spam, nya strider, avbrutna order, dungeon/strid, prioritet, petbyte/död, inställningar och migrering.

Kommandovägarna kontrollerades mot Blizzards Classic Era-kod: [pet-knappar och tangentbindningar](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_ActionBar/Shared/PetActionBar.lua), [skyddade pet-knappar](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua) och [pet-kommandon i makron](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_ChatFrameBase/Shared/SlashCommands.lua). Simuleringen verifierar våra reaktioner, men bevisar inte att ljud hörs eller att kommandovägarna fungerar i den körande spelklienten.

Spelkontroll efter `/reload`: kontrollera version 1.6.5, skicka pet mot en vanlig fiende med den knapp eller det makro du använder och kalla tillbaka med Follow. Förväntat: CHARGE och sedan en vissling, utan upprepning när du trycker samma knapp flera gånger. Kontrollera även i en dungeon. Ljudet ska följa dina kommandon och pet ska bete sig som vanligt.

Återställningskopia före ändringen: `local-artifacts/before`.

## Automatiska dungeonsvar i 1.6.4

- I femmannadungeons besvaras aktiverade, igenkända riktade emotes automatiskt, även i strid. Svarsrutor och deras förhandsvisningar visas aldrig där. Raids och battlegrounds har kvar tidigare beteende.
- Kontexten avgör svaret: exempelvis WAIT vid en healingförfrågan när spelaren har låg mana eller kastar en spell, NO vid en förolämpning och ett passande socialt svar vid flirt eller kram. Intima mottagare och spelarens beredskap kontrolleras igen före uppspelning.
- Dungeonregeln hoppar över den vanliga svarschansen och inställningen som pausar direktsvar i strid utanför dungeons. Den gemensamma prioriteringen, samtalens cooldown, uttryckligen avstängda funktioner/kategorier, ignorerade spelare och klientens begränsningar gäller fortfarande. Fri text och okända emotes förblir tysta.
- En befintlig popup stängs vid inträde. Väntande dungeonsvar avbryts vid utträde och gamla frågor spelas inte upp efteråt. Ingen sparad inställning behöver ändras; schemaversionen är fortsatt 163.
- Baslinjen passerade 112 tester. De 14 tillagda testerna täcker dungeonval, strid, beredskap, mottagarbyte, svarskedjor, prioritet, avstängningar, klientblockering, fri text, popupvägar, instansbyten och andra instanstyper. Den första nya regressionen misslyckades före kodändringen. Samtliga 126 tester och syntaxkontrollen för sex Lua-filer passerar efter ändringen.
- Ändringen är verifierad med simulering. Hörbar röst, verklig timing och menyernas utseende har ännu inte kontrollerats i spelklienten.

Spelkontroll: kör `/reload`, kontrollera version 1.6.4 och prova riktad emote mellan er i en dungeon, både under vanlig strid och utanför strid. Det ska bli ett automatiskt svar när cooldown och kontext tillåter, utan ruta. Gå sedan ut och kontrollera att en riktad flirt åter kan ge ett svarsförslag. Samma version behöver installeras hos båda spelarna.

Återställningskopia före ändringen: `local-artifacts/before`.

## Sociala svar, manapauser och pets i 1.6.3

- Tydligt riktat MOO får MOO från Tauren och LAUGH från andra raser. Samtalsgränser stoppar svarskedjor, även när spelaren manuellt har skrivit /moo.
- Riktad WHISTLE, SIGH, YAWN och BORED har egna svarval. Vissling behandlas inte automatiskt som flirt. Otydliga och egna textemotes kräver fortfarande ett val; oriktade emotes öppnar ingen popup.
- `manaBreak`: WAIT vid faktisk Drink-buff och högst 60 % mana i ett lugnt party. Signalen ges en gång per berättigad paus; redan köad OOM och extra WAIT får lämna plats.
- `manaReady`: NOD när en annonserad paus avslutats efter minst tre sekunder med minst 90 % mana. Att börja gå med tillräcklig mana är ett normalt avslut. Tidig avbruten paus, strid, ny grupp, nya inställningar eller blockerat WAIT ger inget falskt klartecken.
- `petDanger`: HELPME vid högst 25 % pet-hälsa under strid, med återaktivering vid 60 %. Spelarens egna akuta varningar har högre prioritet.
- `petDeath`: MOURN/CRY efter bekräftad död, först efter striden och inom 45 sekunder. Avskedande och saknad hälsodata räknas inte som död. Återupplivning eller byte av pet avbryter väntande sorg.
- De fyra nya scenarierna ger totalt 33 inställningsbara scenarier, plus det fasta partyavskedet och direktsvar. Quiet lämnar nytillskotten avstängda. Befintliga egna val bevaras.
- Ny modul: HCVoice_Situations.lua. Inga nya ljudfiler eller nya rösttoken tillkommer; pet-reaktionerna är spelarens egna Blizzard-emotes.

Drickbuffarnas ID:n och emote-texterna kontrollerades mot klienttabeller för Classic Era 1.15.9.69547: [SpellName](https://github.com/Vladinator/wow-dbc-archive/blob/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae/spellname.csv) och [EmotesTextData](https://github.com/Vladinator/wow-dbc-archive/blob/3f5d16ddd405ac5bb508e0b342d4db50b35c7eae/emotestextdata.csv). Auraläsningen följer [Classic Era UnitAura](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_APIDocumentationGenerated/UnitAuraDocumentation.lua), med äldre UnitBuff som reservväg. Endast identifierade Drink-buffar räknas, inte vanlig manaregenerering eller godtycklig mat.

## Nya emotes i 1.6.2

- HUG behålls som ett uttryckligt RP-undantag. Det är fortsatt ett frivilligt kontextuellt svar utan separat aktivering, och visas som RP-interaktion i Voice Lab.
- BORED, YAWN och WHISTLE väljs vid lång, stillastående och lugn väntan, solo eller i party. Standard är fem minuters väntan, 15 % grundchans och tio minuters cooldown. Befintliga inställningar och lokal frekvens respekteras.
- Idle-emotes riktas inte mot någon, skickar ingen Living World-scen och startar inget omedelbart partyskämt.
- MOO kan ibland ersätta JOKE under lugn partyresa eller väntan, endast för Tauren. Rasvillkoret gäller slumpval, menyer och det slutliga emote-anropet.
- SIGH behåller sina befintliga scenarier för lättnad, återhämtning och besvikelse. YAWN och SIGH fanns redan och har inte dubblerats.
- Rörelse avbryter idle; casting, channeling, strid hos en partymedlem, döda partymedlemmar och raid förhindrar nya väntansreaktioner. Samma villkor kontrolleras när kön ska spela upp reaktionen. Allvarliga ögonblick får fortsatt företräde.
- Voice Lab har 42 registrerade alternativ inklusive HUG; 41 är tillgängliga för andra Classic-raser än Tauren. Inga externa ljudfiler tillkommer.

Ljudurvalet kommer från klientdata för den installerade Classic Era-versionen 1.15.9.69547; se EMOTE_REFERENCE.md för källor och begränsningar. SIGH/BORED/YAWN/WHISTLE har direkta ljudkopplingar för Classic-raserna, MOO endast för Tauren. Den tidigare versionen har rapporterad speltestning; de nya tilläggen är ännu inte speltestade i denna verifiering.

## Användarens korrigeringar i 1.6.1

- Intima svar kräver ingen separat aktivering. FLIRT, KISS och HUG finns direkt som kontextuella popupval. Den gamla aktiveringsrutan och profilinställningen tas bort.
- Varje observerat party-/raidavhopp ger exakt BYE till den som lämnar medan HCV är på. Ingen slumpchans, cooldown, minsta grupptid eller stridsspärr gäller. Även Quiet omfattas.
- Väntande välkomsthälsning till den avgående spelaren avbryts. Upprepade rosteruppdateringar upprepar inte avskedet. Initialisering och uttrycklig rosteråterställning skapar inga avsked.
- Spelklientens blockering respekteras; ett blockerat BYE upprepas inte och öppnar ingen popup.

## Buffregeln

- Att ge en buff skapar ingen emote eller nytt socialt möte.
- En väntande HELLO till spelaren som buffas avbryts, även om den hunnit hamna i kön.
- Mottagna viktiga buffs kan fortfarande ge ett riktat THANK. Flera samtidiga buffs från samma hjälpare ger ett tack.
- Den tidigare mottagningsfördröjningen på 0,5 sekunder har bevarats. Därefter gäller den gemensamma sociala kön.
- Self-buffs och passiva auror ger inget tack. Det gamla inställningsfältet för utgående buffs tas bort vid migrering.

## Genomfört

Den gemensamma reaktionsmotorn kontrollerar aktualitet, mottagare, pågående strid, aktuella inställningar, upprepningar och prioritet före uppspelning. Den hanterar vanliga scenarier, direktsvar och Living World. På/Av och profilbyte avbryter gamla fördröjda jobb.

Social tolkning har flyttats till en egen modul. Spelarnamnet tas bort från tolkningen, känsliga betydelser prioriteras, och fri text besvaras aldrig automatiskt. Popupens mottagare kan inte ersättas under ett aktivt val. Hälsning och tacksamhet har skilda samtalsgränser.

Scenarierna har fått mer återhållsamma val efter död och allvarlig fara. Healing räknas effektivt per hjälpare. Handel använder den faktiska handelspartnern och väntar på bekräftelse. Grupproster, level och dödsfall omfattar även raiden.

Living World använder version 2 av scenprotokollet och tar emot äldre version-1-scener. Nya scener ignoreras av gamla klienter, vilket gör att alla deltagande HCV-klienter bör uppdateras för full samordning. Småprat tilldelas högst en känd kompatibel svarare. Simulationer skickar inte svar till den riktiga gruppen.

Förinställningarna styr hela automatiken. Direktsvar, lokala initiativ och delade scener har separata frekvenskontroller. Det finns en lokal historik över de senaste 50 besluten.

## Verifierat automatiskt

- Samtliga sex laddade Lua-filer klarar syntaxkontroll för Lua 5.1.
- 145 beteendetester med simulerad klocka, spelhändelser, gruppmedlemmar och UI-objekt passerar.
- 33 nya tester i 1.6.3 täcker nya sociala svar, egen manuell MOO, verklig drickbuff, avbrutna/färdiga pauser, spärrade anrop, rörelse, strid, grupp- och profilbyten, dubbletter, reserv-API, pet-varningar/död, prioritet, återhämtning, försvinnande och Quiet-migrering.
- 17 nytillkomna tester täcker lång väntan solo/party, alla tre idle-varianterna, fördröjning, cooldown, rörelse/casting/channeling, partystrid/död, raid, rasvillkor vid val och anrop, avbruten MOO efter gruppupplösning, allvarliga ögonblick, frånvaro av idle-svarskedjor, profilmigrering och Voice Lab inklusive bevarad HUG.
- Nya tester täcker FLIRT/KISS/HUG utan separat aktivering, uppgraderade profiler, korta och samtidiga partyavhopp, upprepad avgång, strid, Quiet, avstängning, blockerade anrop och avbruten välkomsthälsning.
- Tester omfattar buffregeln inklusive väntande target-hälsningar, varningsprioritet och återhämtning, avstängning, profilbyte, emote-tolkning, popupens stabilitet, känsliga val, handel, healing, raid, dubbelsvar och protokollhantering.
- Samma grupphändelse och hälsning testas genom både lokal/synlig och synkroniserad upptäckt. Svarsmarkörer stoppar nya automatiska svarskedjor.
- Inga vanliga chattmeddelanden används. Testberoendena ligger utanför den installerade addonens runtime.

## Återstående spelkontroll

Automatiska tester bevisar inte hörbar röst, visuell layout eller hur naturligt tempot upplevs. Ingen spelklient har styrts eller observerats under implementationen.

Efter /reload:

1. Kontrollera att /hcv visar 1.6.5 och att fönster samt popup ryms på skärmen. Prova riktad WHISTLE, SIGH, YAWN, BORED och MOO mellan två spelare. HUG finns kvar som RP-val utanför dungeons.
2. Buffa en annan spelare: inget utgående buff-emote. Ta emot en buff: ett riktat tack när tillfället tillåter det.
3. Prova riktad hälsning, flirt och förolämpning. I dungeons sker svaren automatiskt. Utanför dungeons kan hälsning besvaras automatiskt och de två senare ge ett frivilligt val enligt kategorierna.
4. Kontrollera ljud och tempo under vanlig spelning när HP eller mana naturligt blir låg och återhämtas. Testerna kräver ingen avsiktlig farlig situation.
5. Prova en grupp med flera uppdaterade HCV-klienter och en grupp med spelare utan HCV. Kontrollera gemensamt firande, högst en småpratssvarare och att inga svarskedjor startar.
6. Kontrollera en vanlig slutförd och en avbruten trade samt On/Off medan en reaktion väntar.
7. Låt en partymedlem lämna direkt efter inträde och efter längre grupptid: BYE ska triggas i båda fallen. Kontrollera också att intima popupval finns utan separat aktivering.
8. Drick vid ett naturligt tillfälle i party med låg mana: ett WAIT, sedan NOD först efter tillräcklig återhämtning och avslutad paus. Kontrollera även en paus som avslutas för tidigt.
9. Kontrollera pet-reaktioner när relevanta situationer uppstår naturligt. Att bara avskeda/kalla tillbaka pet ska vara tyst. Utsätt inte karaktären eller pet för avsiktlig fara för att testa.

TOC:s klientmål 11509 har behållits. Engelska standardemotes och buffnamn är det stödda textunderlaget; andra språk är inte nyverifierade.

Blizzards API styr om ett emote får utföras. Historikens ”attempted” betyder att anropet slutfördes, inte att ljudet säkert hördes. Tidigare hantering av klientens false-resultat har behållits för att undvika upprepade anrop.

API-struktur kontrollerades mot [Classic Era ChatInfo-källan](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_APIDocumentationGenerated/ChatInfoDocumentation.lua) och handelspartnern mot [Classic Era TradeFrame-källan](https://raw.githubusercontent.com/Gethe/wow-ui-source/classic_era/Interface/AddOns/Blizzard_UIPanels_Game/Classic/TradeFrame.lua). Dessa är källkontroller, inte speltestbevis.

## Återställning och utveckling

Lokala återställningskopior skapades före dessa ändringar:

- Naturliga reaktioner: 2026-09-06, före implementation.
- Version 1.6.1: 2026-09-06, kopia av 1.6.0.
- Version 1.6.2: 2026-09-07, kopia av 1.6.1.
- Version 1.6.3: 2026-09-07, kopia av 1.6.2.

Maskinspecifika sökvägar har utelämnats. Kopiornas nuvarande tillgänglighet är inte kontrollerad här.

Inga sparade användarinställningar i WTF har öppnats eller skrivits direkt. Inställningsmigrering sker vid nästa laddning av addonets kod. Användarens befintliga mottagningsfördröjning för buffs bevarades i koden.

Testerna finns i tests/behavior.lua och tests/run.cjs. Sätt HCV_TEST_DEPS till en utvecklingsmapp med luaparse 0.3.1 och fengari 0.1.5 och kör node tests/run.cjs från valfri katalog. Testkoden ingår inte i TOC eller installationspaketets runtime.
