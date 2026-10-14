# Plan: naturligare beteende i HCVoice

Datum: 2026-09-06. Utgångspunkt: installerad HCVoice 1.5.0.
Status: genomförd i kod som HCVoice 1.6.1 med användarens ändringar: egen buff är tyst, intima svar saknar separat aktiveringskrav och varje observerat partyavhopp ger BYE. Lua 5.1-syntax och 62 simulerade beteendetester har godkänts. Verklig röstuppspelning, slutlig layout och tajming återstår att prova i Classic Era; se IMPLEMENTATION_HISTORY.md.

## Mål och grundregler

HCV ska kännas som en karaktär som deltar i det som händer. En reaktion ska ha rätt betydelse, rätt mottagare och rätt tajming. Tystnad ska vara ett normalt resultat när tillfället har passerat, sammanhanget är oklart eller samma sak redan har sagts.

Varje automatisk reaktion måste besvara fem frågor: Vad hände? Berör det mig? Vem gäller det? Passar reaktionen fortfarande? Har jag redan reagerat?

Följande befintliga beteenden bevaras:

- Medveten markering av en lämplig spelare utanför gruppen kan ge HELLO. Gruppmarkering, NPC-fönster och enbart närhet startar ingen hälsning. Neutral, icke attackerbar spelare förblir ett giltigt hälsningsmål.
- Tydliga riktade hälsningar och tack kan besvaras automatiskt. Flirt, förolämpningar och andra riktade emotes som kräver ett val kan ge ett frivilligt popupförslag.
- Intima svar finns direkt som popupval utan separat aktivering. Taktiska initiativ som CHARGE förblir manuella.
- När någon lämnar partyt ges alltid BYE medan HCV är på. Ingen slumpchans, cooldown, minsta grupptid eller stridsspärr gäller för detta avsked.
- Händelser som loot, buffs, bossar och Living World öppnar inga popupförslag. En blockerad automatisk reaktion förblir tyst.
- Befintliga Blizzard-emotes, lokal kontroll och karaktärsspecifika inställningar behålls. Vanliga chattmeddelanden och externa ljud behövs inte.
- Röstvariation får påverka hur en passande reaktion uttrycks. Den får inte ändra reaktionens betydelse.

Planens rekommenderade standard är levande men återhållsam. Högre uttrycksfullhet får ge fler passande tillfällen och mer variation, med samma krav på sammanhang.

## 1. Samla alla beslut om reaktioner

Först samordnas den vanliga reaktionskön, automatiska direktsvar och Living World. De behöver samma kontroll av inställningar, mottagare, aktualitet, upprepning och prioritet. Manuell uppspelning och klickade svar behåller sin direkta användarstyrning men registreras i samma historik, så automatiken kan lämna plats åt dem.

Varje reaktion får ett tydligt sammanhang: händelse, avsändare/mottagare, tillhörande strid eller möte, prioritet, senaste giltiga tid och villkor för att fortfarande få spelas.

- Separera akuta stridsrop, sociala svar och småprat. Social väntetid ska inte ensam hålla tillbaka ett nytt akut läge. Behåll en kort gemensam spärr mot tätt överlappande automatiska röster.
- Kontrollera sammanhanget både när reaktionen skapas och omedelbart före uppspelning. Avbryt gamla varningar efter återhämtning och sociala reaktioner som inte längre passar.
- Samordna flera signaler från samma ögonblick. Ett stort slag som utlöser HELPME, HEALME och FLEE ska ge det mest relevanta aktuella ropet; svagare inaktuella rop ska inte komma efteråt.
- Avbryt väntande jobb vid avstängning, profilbyte och andra tillståndsbyten som gör dem ogiltiga. GUI-knappen och /hcv off ska göra samma sak.
- En markerad utlösare får inte fastna som redan hanterad om dess reaktion aldrig kunde tas emot av kön. Skilj mellan upptäckt, väntande, försökt och avbruten reaktion, med skydd mot täta återförsök.

Startvärden att utvärdera: ungefär 0,1–0,3 sekunders sammanläggning av akuta signaler, 0,6–1,5 sekunders naturlig paus för sociala svar och 1–3 sekunders spridning för gemensamma firanden. Hälsningens nuvarande väntetid och användarens egna gränser bevaras vid uppgradering.

Klart när: en hälsning inte orsakar flera sekunders onödig väntan för en nödsignal, en färdighealad spelare inte får ett gammalt HEALME och avstängning stoppar även väntande reaktioner. Faktiskt ljud och klientens tillåtna uppspelning måste verifieras i spelet.

## 2. Ge varje situation ett tydligt beteende

Gå igenom samtliga befintliga scenarier och dokumentera utlösare, betydelse, mottagare, aktualitet, standardläge och vilka andra reaktioner som får ersätta dem. Lokala och synkroniserade versioner av samma situation ska följa samma regler.

| Situation | Planerat naturligt beteende |
| --- | --- |
| Första relevanta fientliga träffen | Bevara HELPME-scenariots betydelse. Samordna det med starkare samtidiga farosignaler och undvik senare upprepning av samma öppningsögonblick. |
| Låg hälsa | HEALME när hjälp fortfarande behövs. Avbryt efter återhämtning; återaktivera först enligt återhämtningsgränsen. |
| Akut fara | FLEE prioriteras framför mindre akuta och sociala reaktioner. Ett nytt verkligt nödläge får inte tappas bort bakom gammalt småprat. |
| Låg mana | Ett relevant OOM med ny kontroll vid uppspelning. Inga försenade OOM efter att mana kommit tillbaka. Samordna rutinbuffning och återhämtning så de inte skapar ett återkommande varningsmönster. |
| Ytterligare fiende | INCOMING när en ny fiende faktiskt påverkar striden. Skilj en upptrappning från samma fiendes upprepade skada och redan kända fiender. |
| Hjälp från annan spelare | THANK till den som faktiskt bidrog. Samla buffserier och läkningshändelser till ett tack för ett sammanhängande hjälptillfälle. |
| Egen buff på annan spelare | Ingen emote. Användaren ändrade detta uttryckligen före implementation. Ta bort scenariot och dess inställning samt avbryt eventuell väntande target-hälsning när spelaren buffas. Tack behålls för mottagna buffs. |
| Klarad svår strid | Fira bekräftad framgång efter att situationen lugnat sig. Bedöm boss, rutinmässig elit och verkligt svår kamp separat. |
| Nära döden | En återhållsam lättnadsreaktion när spelaren är säker. Ta bort skämt och triumf från standardvalen för allvarlig fara. |
| Gruppmedlem dör | En respektfull reaktion när situationen tillåter det. Dödsfallet ska väga tyngre än ett samtidigt firande eller skämt. |
| Återupplivning och wipe | Reagera bara på faktiskt återvändande till livet. Skilj detta från död och spöktillstånd; relevant funktionalitet ska anpassas till speltypen. |
| Level och värdefull loot | En passande reaktion per relevant tillfälle. Samordna level, bossvinst och loot som inträffar tätt så de inte blir en lång efterföljande kö. |
| Trade | THANK efter bekräftat slutförd mottagning och till verifierad handelspartner. Ett markerat target eller ett stängt handelsfönster ska inte ensamt räcka som bevis. |
| Grupp bildas eller upplöses | Hälsningar kan samordnas. Varje observerad avgång ger däremot ett riktat BYE, även efter kort grupptid eller när flera lämnar samtidigt. Väntande välkomsthälsning till den avgående spelaren avbryts. Initial rosterläsning ger inga avsked. |
| Ready check och WAIT | Bekräfta spelarens faktiska ready-val. Ett automatiskt WAIT kräver fortfarande en relevant väntesituation när det ska sägas. |
| Skämt och idle | Sällsynt under trygg resa eller paus. Avbryt när strid börjar och ge sorg eller nylig allvarlig fara utrymme innan humor åter blir aktuell. |

Healing behöver räknas per hjälpare och, där eventdatan medger det, efter effektiv healing. Nu summeras healing från flera personer medan mottagaren av tacket väljs från den största enskilda healingen. Planen gör sambandet mellan bidrag och tack tydligt.

Klart när: varje scenario har dokumenterade exempel på både en giltig reaktion och när HCV ska förbli tyst. Variationerna måste också passa sitt eget mål: gratulationer till en spelare och firande av en seger ska inte riktas slentrianmässigt mot samma enhet.

## 3. Gör möten och samtal sammanhängande

Utveckla det korta mötesminne som redan finns. Använd stabil spelaridentitet när den finns och ett entydigt namn som reserv. Samma spelare får inte få skilda minnen beroende på om informationen kommer från target, synliga emotes eller addonmeddelanden.

- Behåll medveten HELLO-hälsning. Ett kort targetbyte under pågående möte ska inte genast ge BYE följt av ett nytt HELLO.
- Kräv ett etablerat möte för avsked vid targetbyte. Kontrollera återkomst, strid och mottagarens relevans innan detta väntande BYE spelas. Partyavhopp ger alltid BYE direkt och omfattas inte av dessa villkor.
- Modellera enkla utbyten: HELLO → HELLO och THANK → WELCOME avslutar normalt den sekvensen. En ny, separat handling kan starta ett nytt tillfälle utan att öppna för ändlösa svarskedjor.
- Registrera även spelarens egna manuella emotes där klienten ger tillräcklig information. Automatiken ska undvika att omedelbart upprepa något spelaren redan har sagt.
- Samordna buffning, tack och mötesminne. Ett buffutbyte ska inte råka bli tre parallella sociala händelser.

Klart när: två HCV-användare kan hälsa och tacka utan loopar; targetbyte under samma samtal skapar inte HELLO/BYE-pendling; ett nytt meningsfullt tillfälle kan fortfarande få ett svar.

## 4. Tolka emotes säkrare och förbättra popupen

Tolkningen ska skilja avsändare och mottagare från själva handlingen. Dagens sökning efter delsträngar i hela meddelandet kan låta spelarnamn påverka kategorin och behandlar standardemotes och fritt skriven emote-text på samma sätt.

- Prioritera verifierbara standardformuleringar och tydlig mottagarinformation. Kontrollera möjligheterna mot aktuell Classic Era-dokumentation via Context7 och klientens tillgängliga data innan implementation.
- Behandla fri text försiktigare. Ett vänligt ord i en förolämpning får inte räcka för ett automatiskt vänligt svar. Oklar text ger tystnad eller, om den säkert är riktad och kategorin tillåts, ett förslag.
- Behåll automatiken för tydliga riktade hälsningar och tack. Flirt, förolämpningar, intimitet och valkrävande förfrågningar förblir spelarens beslut.
- Utgå från det befintliga engelska stödet. Visa tydligt vilket språk som är verifierat; andra klientlokaler får stöd när motsvarande texter har kontrollerats och testats.
- Visa ett litet, flyttbart förslag med tydlig avsändare, originalmeddelande och passande val. Spara positionen och gör layouten användbar vid olika UI-skalor.
- Byt inte mottagare eller knappbetydelse under ett pågående val. Nya förslag kan väntas kort eller släppas; en gammal kö av sociala frågor ska inte visas efter att tillfället passerat.
- Behåll avfärda och ignorera. Förslag är fortsatt frivilliga och kan aldrig automatiskt välja ett känsligt svar åt spelaren.

Klart när: namn som innehåller hälsningsord inte ändrar klassificeringen, emotes till andra personer inte orsakar förslag och ett klick inte råkar besvara en ny avsändare som ersatt den gamla.

## 5. Samordna Living World med resten av HCV

Behåll befintliga spärrar för dubbletter, avsändarfrekvens och svarsdjup. Förbättra identifieringen av vilket faktiskt tillfälle en reaktion tillhör.

- Slå ihop lokal upptäckt, synlig emote och strukturerat meddelande endast när de gäller samma tillfälle. Dagens korta spärrar per avsändare behöver ersättas eller kompletteras så att en separat flirt inte försvinner efter en annan scen.
- Vid stora gemensamma händelser får varje berättigad HCV-spelare reagera högst en gång, med en kort tidsförskjutning. Klass eller roll får inte utesluta någon från gemensamma ögonblick.
- Välj högst en automatisk svarare på småprat bland användare som faktiskt kan delta. Nu väljs svarare ur hela partylistan, även spelare som kanske inte kör HCV. En liten versions-/deltagaridentifiering utvärderas; frånvaro av verifierad deltagare får ge tystnad.
- Kontrollera gruppmedlemskap, aktuella inställningar, ignorering och stridsläge igen när ett fördröjt svar ska spelas. Hantera gruppbyte och zonbyte utan gamla callbacks.
- Ge party och raid tydligt dokumenterad täckning. Lokala kontroller som i dag bara tittar på party1–party4 behöver granskas innan en funktion utlovas för hela raiden.
- Behåll kompakta semantiska meddelanden. En eventuell protokolländring ska hantera äldre HCV-versioner förutsägbart och undvika dubbla svar.

Klart när: samma bossvinst inte får både lokal och synkroniserad reaktion från samma spelare, småprat inte ger en svarskör och blandade grupper med och utan HCV fungerar utan beroende av att alla installerat addonet.

## 6. Gör inställningar och profiler begripliga

Behåll befintliga profilnamn vid uppgradering men gör deras effekt fullständig och tydlig. Quiet begränsar automatiken till uttryckligen valda viktiga tillfällen; Balanced, Classic RP och Full RP ökar deltagandet stegvis utan att lossa reglerna för betydelse och känsliga svar.

- Alla förinställningar ska beskriva och styra lokala reaktioner, direktsvar och Living World tillsammans. Ta bort gamla inställningar som inte längre påverkar beteendet eller koppla dem till en enda ansvarig kontroll.
- Skilj på hur ofta karaktären tar ett socialt initiativ, besvarar en direkt handling och deltar i gemensamma händelser. En enda frekvensprocent ska inte dölja tre olika beteenden.
- Visa alla scenarier där spelaren förväntar sig att hitta dem. Bland annat behöver tack för stridshjälp och återupplivning finnas med i den aktuella inställningssidans urval.
- Samma På/Av-funktion används av GUI och kommandon och rensar väntande automatisk aktivitet. Manuella tester förblir möjliga när automatiken är av.
- Bevara egna val, profiler och intimitetsinställningar vid migrering. Inför inte nya aktiva känsliga svar genom en vanlig uppdatering eller en mer livlig förinställning.
- Validera trösklar direkt när de ändras, liksom vid profilimport. Importerad text fortsätter att vara inställningsdata som aldrig körs som kod.
- Voice Lab ska beskriva den aktuella betydelsen och ge ett separat testläge. Uppdatera hjälpinformation, README och changelog efter det slutliga beteendet.

Klart när: Quiet ger den effekt beskrivningen lovar, varje synlig kontroll påverkar rätt funktion och befintliga anpassningar överlever uppdateringen.

## 7. Lägg till insyn och håll koden lätt att underhålla

En liten lokal historik, exempelvis de senaste 50 besluten, ska kunna öppnas vid felsökning: upptäckt händelse, tänkt reaktion och varför den försöktes eller valdes bort. Exempel: ”HEALME bortvald: hälsan återhämtad” eller ”HELLO bortvald: samma möte pågår”. Historiken behöver inte skriva löpande i chatten.

- Skilj mellan ett anrop som försöktes och vad klienten faktiskt bekräftar. Ett lyckat Lua-anrop är inte ensamt bevis för att en röst hördes. Bevara skyddet mot att misstolka ett false-resultat som skäl att spamma återförsök.
- Dela vid behov den stora huvudfilen i en liten kärna, reaktionsregler och social tolkning. Behåll Living World och GUI som egna delar. Flytta endast kod som behövs för tydligt ansvar och meningsfulla tester.
- Begränsa historik, mötesminnen, cooldown-tabeller och väntande händelser. Rensa gamla poster regelbundet och undvik onödigt arbete för irrelevanta combat-log-event.
- Dokumentera scenarioregler på ett ställe så att runtime, GUI och hjälpinformation inte utvecklar olika betydelser.

Klart när: en felaktig eller utebliven reaktion kan förklaras med en konkret beslutskedja utan att vanlig spelning fylls med debugtext.

## 8. Genomför och verifiera i avgränsade steg

1. Spara en återställbar kopia av den installerade addonversionen. Skapa en baslinje av befintliga beteendetester för popupregler, HELLO, buffs och dubbelsvar.
2. Implementera gemensam kö, giltighetskontroller, avstängning och prioritering. Testa tidsförlopp med simulerad klocka, särskilt återhämtning och fördröjda callbacks.
3. Förfina scenariernas betydelse och mottagare. Testa verkliga sekvenser: farlig strid → healing → överlevnad → tack; bossvinst med och utan gruppdödsfall.
4. Implementera sammanhängande mötesminne, emote-tolkning och stabil popup. Testa standardemotes, fri text, svårtolkade namn och snabba nya meddelanden.
5. Koppla Living World till samma regler. Testa båda ordningsföljderna för lokal upptäckt och meddelande, dubbletter, gamla meddelanden, gruppbyten och blandade addonversioner.
6. Uppdatera inställningar och migrering. Testa egna profiler, import/export, alla förinställningar, GUI-avstängning och slash-kommandon.
7. Kör Lua-syntaxkontroll och relevanta regressionstester. Verifiera paketinnehåll och uppdatera versions-/TOC-information endast till det klientstöd som faktiskt har kontrollerats.
8. Prova inne i Classic Era: solo, vanlig party, dungeon, raid där funktionerna stöds samt grupp med flera och utan HCV-användare. Kontrollera verklig röstuppspelning, popupens placering och tempot mellan reaktionerna. Kalibrera först därefter standardtider och frekvenser.

### Godkännandekriterier för naturligt beteende

- Ingen automatisk röst från väntande jobb efter att automatiken stängts av.
- Inga kvarvarande varningar för ett tillstånd som redan återhämtats i verifierade testsekvenser.
- Högst en reaktion per spelare på samma identifierade gemensamma tillfälle, oavsett upptäcktsväg.
- Högst en automatisk småpratssvarare per samordnad gruppscen och inga självgående svarskedjor.
- Inga popupförslag från NPC-interaktioner, närhet, loot, buffs, stridshändelser eller synkroniserade scener.
- Tydliga riktade hälsningar hanteras naturligt; riktad flirt och förolämpningar ger val enligt spelarens inställningar.
- Ingen automatisk humor i de definierade sorgesituationerna och ingen lång kö med firanden efter att nästa farliga situation börjat.
- Rätt mottagare för verifierade tack-, handels- och gratulationsscener.
- Förinställningar, egna inställningar och dokumentation beskriver samma faktiska beteende.
- Speltest visar att ljud, tajming och GUI fungerar på den stödda klienten. Godkända kodtester räcker inte ensamma för den slutsatsen.

Kodimplementation och automatiska kontroller är genomförda. Speltesterna i steg 8 återstår; detaljer och bevisgränser finns i IMPLEMENTATION_HISTORY.md.
