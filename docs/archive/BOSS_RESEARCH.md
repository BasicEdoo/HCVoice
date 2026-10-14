# HCVoice – bosskatalog för Classic Era Hardcore

Datum: 2026-09-15. **Implementerat i HCVoice 1.7.0; verkligt speltest återstår.**

## Omfattning och läsning

**26 dungeon-/vingavsnitt och 230 implementerade boss-/möteskort.** Ett kort kan innehålla flera NPC:er i samma möte; siffran är inte antalet unika boss-NPC:er. Samtliga har emoteval, NPC-ID och körbara regler. [Exakta reaktioner och motiveringar finns här](BOSS_REACTIONS_1.7.0.md). Tom ruta betyder att verkligt speltest ännu återstår; simulering och implementation är klara.

Endast befintliga Blizzard-röster/ljud och synliga animationer ska användas. **Inga egna repliker, egen textdialog eller nya ljud.** Se [strukturen och mallen för bosskort](BOSS_REACTIONS_PLAN.md).

Detta är en arbetslista över Era-dungeons med ordinarie bossar, kända rares, questbossar och namngivna specialmöten. Mindre följeslagare anges under sitt möte. Listan är inte en databas över varje trash-NPC. Raids och världsbossar är ett separat framtida innehållspaket.

### Markeringar

- **R:** sällsynt spawn/variant.
- **Q:** questanknutet specialmöte; markeringen betyder inte att bara dessa bossar förekommer i quests.
- **E:** event, frambesvärjning eller särskild aktivering.
- **M:** flera NPC:er/former kopplas till ett gemensamt möte.
- **V:** villkorat/särskilt möte eller namngiven miniboss som behöver egen bedömning.
- Utan markering: ordinarie bosskort. Flera markeringar kan kombineras.

Namnen följer de engelska Era-namnen. NPC-ID:n är uppslagna mot den installerade Classic-databasen; plats och trigger finns i den implementerade listan. Loreanknutna emoteval är RP-tolkningar. Verkliga klienthändelser och uppspelning behöver fortfarande provas per möte. Inga rekommenderade Hardcore-nivåer eller påståenden om säkra strider följer av denna lista.

## Översikt

| Nr | Dungeon / vinge | Kort |
|---|---|---:|
| 01 | Ragefire Chasm | 4 |
| 02 | Wailing Caverns | 9 |
| 03 | The Deadmines | 8 |
| 04 | Shadowfang Keep | 9 |
| 05 | The Stockade | 6 |
| 06 | Blackfathom Deeps | 8 |
| 07 | Gnomeregan | 6 |
| 08 | Razorfen Kraul | 9 |
| 09 | Scarlet Monastery – Graveyard | 5 |
| 10 | Scarlet Monastery – Library | 2 |
| 11 | Scarlet Monastery – Armory | 1 |
| 12 | Scarlet Monastery – Cathedral | 2 |
| 13 | Razorfen Downs | 6 |
| 14 | Uldaman | 8 |
| 15 | Zul'Farrak | 12 |
| 16 | Maraudon | 10 |
| 17 | The Temple of Atal'Hakkar / Sunken Temple | 13 |
| 18 | Blackrock Depths | 33 |
| 19 | Lower Blackrock Spire | 16 |
| 20 | Upper Blackrock Spire | 8 |
| 21 | Dire Maul – East | 5 |
| 22 | Dire Maul – West | 7 |
| 23 | Dire Maul – North | 6 |
| 24 | Scholomance | 16 |
| 25 | Stratholme – Live / Scarlet | 13 |
| 26 | Stratholme – Undead / Scourge | 8 |

## 01. Ragefire Chasm

**Planeringsfokus:** Utgå från grottans invånare och Searing Blade; håll reaktionerna korta.

Underlag: [Era-guide för Ragefire Chasm](https://www.wowhead.com/classic/guide/classic-dungeons-overview). Fokus och framtida emoteval är våra designförslag.

- [ ] `rfc-01` Oggleflint
- [ ] `rfc-02` Taragaman the Hungerer
- [ ] `rfc-03` Jergosh the Invoker
- [ ] `rfc-04` Bazzalan

## 02. Wailing Caverns

**Planeringsfokus:** Håll isär de korrumperade druiderna, grottans djur och Naralex-eventet.

Underlag: [Era-guide för Wailing Caverns](https://www.wowhead.com/classic/guide/wailing-caverns-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `wc-01` Lady Anacondra
- [ ] `wc-02` Lord Cobrahn
- [ ] `wc-03` Kresh
- [ ] `wc-04` Lord Pythas
- [ ] `wc-05` Skum
- [ ] `wc-06` Lord Serpentis
- [ ] `wc-07` Verdan the Everliving
- [ ] `wc-08` Mutanus the Devourer [E]
- [ ] `wc-09` Deviate Faerie Dragon [R]

Eventkoppling: Disciple of Naralex, ritualens steg och Naralex uppvaknande kopplas till Mutanus-kortet. Escortstart är inte en bossseger.

## 03. The Deadmines

**Planeringsfokus:** Maskiner, Defias och skeppets besättning ger olika tillfällen. Shreddern och Sneed delar slutvillkor.

Underlag: [Era-guide för The Deadmines](https://www.wowhead.com/classic/guide/deadmines-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `deadmines-01` Rhahk'Zor
- [ ] `deadmines-02` Miner Johnson [R]
- [ ] `deadmines-03` Sneed's Shredder / Sneed [M]
- [ ] `deadmines-04` Gilnid
- [ ] `deadmines-05` Mr. Smite
- [ ] `deadmines-06` Captain Greenskin
- [ ] `deadmines-07` Cookie
- [ ] `deadmines-08` Edwin VanCleef

## 04. Shadowfang Keep

**Planeringsfokus:** Skilj Arugal och hans worgen från slottets spöken. Granska vem en respektfull gest faktiskt passar.

Underlag: [Era-guide för Shadowfang Keep](https://www.wowhead.com/classic/guide/shadowfang-keep-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `sfk-01` Rethilgore
- [ ] `sfk-02` Razorclaw the Butcher
- [ ] `sfk-03` Baron Silverlaine
- [ ] `sfk-04` Commander Springvale
- [ ] `sfk-05` Odo the Blindwatcher
- [ ] `sfk-06` Deathsworn Captain [R]
- [ ] `sfk-07` Fenrus the Devourer
- [ ] `sfk-08` Wolf Master Nandos
- [ ] `sfk-09` Archmage Arugal

## 05. The Stockade

**Planeringsfokus:** Fängelseupproret ger en annan ton än monsterjakt; varje namngiven fånge får egen bedömning.

Underlag: [Era-guide för The Stockade](https://www.wowhead.com/classic/guide/the-stockade-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `stockade-01` Targorr the Dread
- [ ] `stockade-02` Kam Deepfury
- [ ] `stockade-03` Hamhock
- [ ] `stockade-04` Dextren Ward
- [ ] `stockade-05` Bazil Thredd
- [ ] `stockade-06` Bruegal Ironknuckle [R]

## 06. Blackfathom Deeps

**Planeringsfokus:** Använd dungeonens Era-utförande. Eldarna och deras vågor är ett eget miljöevent.

Underlag: [Era-guide för Blackfathom Deeps](https://www.wowhead.com/classic/de/guide/blackfathom-deeps-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `bfd-01` Ghamoo-ra
- [ ] `bfd-02` Lady Sarevess
- [ ] `bfd-03` Gelihast
- [ ] `bfd-04` Lorgus Jett [V]
- [ ] `bfd-05` Baron Aquanis [Q]
- [ ] `bfd-06` Old Serra'kis
- [ ] `bfd-07` Twilight Lord Kelris
- [ ] `bfd-08` Aku'mai

## 07. Gnomeregan

**Planeringsfokus:** Maskiner och haverier ger visuella reaktioner; Grubbis-eventet och Thermapluggs mekaniker granskas separat.

Underlag: [Era-guide för Gnomeregan](https://www.wowhead.com/classic/guide/gnomeregan-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `gnomeregan-01` Grubbis / Chomper [E, M]
- [ ] `gnomeregan-02` Viscous Fallout
- [ ] `gnomeregan-03` Electrocutioner 6000
- [ ] `gnomeregan-04` Crowd Pummeler 9-60
- [ ] `gnomeregan-05` Dark Iron Ambassador [R]
- [ ] `gnomeregan-06` Mekgineer Thermaplugg

## 08. Razorfen Kraul

**Planeringsfokus:** Eget kort för ledarna och de stora djuren. Följeslagare får inte räknas som ett nytt oberoende möte.

Underlag: [Era-guide för Razorfen Kraul](https://www.wowhead.com/classic/guide/razorfen-kraul-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `rfk-01` Roogug [Q]
- [ ] `rfk-02` Aggem Thorncurse
- [ ] `rfk-03` Death Speaker Jargba
- [ ] `rfk-04` Overlord Ramtusk
- [ ] `rfk-05` Agathelos the Raging
- [ ] `rfk-06` Blind Hunter [R]
- [ ] `rfk-07` Earthcaller Halmgar [R]
- [ ] `rfk-08` Charlga Razorflank
- [ ] `rfk-09` Razorfen Spearhide [R, V]

Följeslagare att registrera under rätt kort: Death's Head Ward Keeper, Death's Head Captain och Earth Rumbler. De ska inte ge extra, oberoende bossjubel. Razorfen Spearhide är ett kompletterande rarekort vars placering och status behöver detaljkontroll.

## 09. Scarlet Monastery – Graveyard

**Planeringsfokus:** Förhör och odöda behöver olika uttryck. Rares får egna kort.

Underlag: [Era-guide för Scarlet Monastery – Graveyard](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `sm-graveyard-01` Interrogator Vishas
- [ ] `sm-graveyard-02` Bloodmage Thalnos
- [ ] `sm-graveyard-03` Azshir the Sleepless [R]
- [ ] `sm-graveyard-04` Fallen Champion [R]
- [ ] `sm-graveyard-05` Ironspine [R]

## 10. Scarlet Monastery – Library

**Planeringsfokus:** Hundföraren och Doans magi ger olika reaktioner.

Underlag: [Era-guide för Scarlet Monastery – Library](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `sm-library-01` Houndmaster Loksey
- [ ] `sm-library-02` Arcanist Doan

## 11. Scarlet Monastery – Armory

**Planeringsfokus:** Herods möte behöver även hantera det som händer efter att han faller.

Underlag: [Era-guide för Scarlet Monastery – Armory](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `sm-armory-01` Herod

## 12. Scarlet Monastery – Cathedral

**Planeringsfokus:** Mograine och Whitemane bildar ett flerfasigt möte; första fallet är ingen seger.

Underlag: [Era-guide för Scarlet Monastery – Cathedral](https://www.wowhead.com/classic/guide/scarlet-monastery-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `sm-cathedral-01` High Inquisitor Fairbanks [V]
- [ ] `sm-cathedral-02` Scarlet Commander Mograine / High Inquisitor Whitemane [M]

## 13. Razorfen Downs

**Planeringsfokus:** Håll isär vanliga möten, rare och Belnistrasz-eventet.

Underlag: [Era-guide för Razorfen Downs](https://www.wowhead.com/classic/guide/razorfen-downs-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `rfd-01` Tuten'kash [E]
- [ ] `rfd-02` Mordresh Fire Eye
- [ ] `rfd-03` Glutton
- [ ] `rfd-04` Ragglesnout [R]
- [ ] `rfd-05` Amnennar the Coldbringer
- [ ] `rfd-06` Plaguemaw the Rotting [Q, E]

## 14. Uldaman

**Planeringsfokus:** Väktare, utgrävare och titanspår behöver egna uttryck. Lost Dwarves kräver korrekt fraktionsrelation.

Underlag: [Era-guide för Uldaman](https://www.wowhead.com/classic/guide/uldaman-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `uldaman-01` Revelosh
- [ ] `uldaman-02` The Lost Dwarves: Baelog, Eric "The Swift", Olaf [M, V]
- [ ] `uldaman-03` Ironaya [E]
- [ ] `uldaman-04` Obsidian Sentinel [Q]
- [ ] `uldaman-05` Ancient Stone Keeper
- [ ] `uldaman-06` Galgann Firehammer
- [ ] `uldaman-07` Grimlok
- [ ] `uldaman-08` Archaedas [E]

## 15. Zul'Farrak

**Planeringsfokus:** Pyramiden, fångarna och gongmötet får separata steg; alla NPC:er är inte fientliga hela tiden.

Underlag: [Era-guide för Zul'Farrak](https://www.wowhead.com/classic/guide/zulfarrak-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `zf-01` Antu'sul
- [ ] `zf-02` Theka the Martyr [Q]
- [ ] `zf-03` Witch Doctor Zum'rah
- [ ] `zf-04` Sandfury Executioner [E]
- [ ] `zf-05` Nekrum Gutchewer / Shadowpriest Sezz'ziz [E, M]
- [ ] `zf-06` Sergeant Bly och hans grupp [Q, E, M]
- [ ] `zf-07` Hydromancer Velratha [Q]
- [ ] `zf-08` Chief Ukorz Sandscalp / Ruuzlu [M]
- [ ] `zf-09` Gahz'rilla [E]
- [ ] `zf-10` Zerillis [R]
- [ ] `zf-11` Sandarr Dunereaver [R]
- [ ] `zf-12` Dustwraith [R]

Bly-eventets NPC:er inkluderar Raven, Oro Eyegouge, Murta Grimgut och Weegli Blastfuse. Bevara deras skilda roller och relationer; gruppen ska inte behandlas som fientlig under hela eskort-/pyramidförloppet.

## 16. Maraudon

**Planeringsfokus:** Orange, lila och inre delen hålls ihop i ett avsnitt; respekt kontra hån bedöms från varje boss egen roll.

Underlag: [Era-guide för Maraudon](https://www.wowhead.com/classic/guide/maraudon-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `maraudon-01` Noxxion
- [ ] `maraudon-02` Razorlash
- [ ] `maraudon-03` Lord Vyletongue
- [ ] `maraudon-04` Meshlok the Harvester [R]
- [ ] `maraudon-05` Celebras the Cursed
- [ ] `maraudon-06` Landslide
- [ ] `maraudon-07` Tinkerer Gizlock
- [ ] `maraudon-08` Rotgrip
- [ ] `maraudon-09` Princess Theradras
- [ ] `maraudon-10` De fem khanerna: Kolk, Gelk, Magra, Maraudos, Veng [Q, V]

Khanerna för The Pariah's Instructions har ett gemensamt questkort men behöver separata NPC-identiteter. De finns både före instansportalerna och inne i instansen; kortet får inte förutsätta att alla ligger i samma instansdel.

## 17. The Temple of Atal'Hakkar / Sunken Temple

**Planeringsfokus:** Statyer, trollväktare och drakmöten får egen detektering. Avatar of Hakkar är ett särskilt event.

Underlag: [Era-guide för The Temple of Atal'Hakkar / Sunken Temple](https://www.wowhead.com/classic/guide/temple-of-atalhakkar-sunken-temple-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `st-01` Atal'alarion [E]
- [ ] `st-02` Gasher
- [ ] `st-03` Hukku
- [ ] `st-04` Loro
- [ ] `st-05` Mijan
- [ ] `st-06` Zolo
- [ ] `st-07` Zul'Lor
- [ ] `st-08` Jammal'an the Prophet / Ogom the Wretched [M]
- [ ] `st-09` Dreamscythe
- [ ] `st-10` Weaver
- [ ] `st-11` Morphaz / Hazzas [M]
- [ ] `st-12` Avatar of Hakkar [Q, E]
- [ ] `st-13` Shade of Eranikus

De sex trollväktarna har egna kort men kopplas också till samma barriärförlopp. Hakkari Bloodkeepers hör till Avatar-eventet, inte till fristående bosssegrar.

## 18. Blackrock Depths

**Planeringsfokus:** Dela senare i häkte, arena, valv, verkstad, krog, grav och tronrum. Flera frivilliga event måste identifieras separat.

Underlag: [Era-guide för Blackrock Depths](https://www.wowhead.com/classic/guide/blackrock-depths-detention-block-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `brd-01` Lord Roccor
- [ ] `brd-02` High Interrogator Gerstahn
- [ ] `brd-03` Houndmaster Grebmar
- [ ] `brd-04` Bael'Gar
- [ ] `brd-05` Pyromancer Loregrain [V]
- [ ] `brd-06` Ring of Law: Gorosh the Dervish [E]
- [ ] `brd-07` Ring of Law: Grizzle [E]
- [ ] `brd-08` Ring of Law: Eviscerator [E]
- [ ] `brd-09` Ring of Law: Ok'thor the Breaker [E]
- [ ] `brd-10` Ring of Law: Anub'shiah [E]
- [ ] `brd-11` Ring of Law: Hedrum the Creeper [E]
- [ ] `brd-12` Theldren och arenagruppen [Q, E, M]
- [ ] `brd-13` Lord Incendius
- [ ] `brd-14` Fineous Darkvire
- [ ] `brd-15` Warder Stilgiss / Verek [M]
- [ ] `brd-16` Watchman Doomgrip [E]
- [ ] `brd-17` Dark Keeper Bethek [E]
- [ ] `brd-18` Dark Keeper Ofgut [E]
- [ ] `brd-19` Dark Keeper Pelver [E]
- [ ] `brd-20` Dark Keeper Uggel [E]
- [ ] `brd-21` Dark Keeper Vorfalk [E]
- [ ] `brd-22` Dark Keeper Zimrel [E]
- [ ] `brd-23` General Angerforge
- [ ] `brd-24` Golem Lord Argelmach
- [ ] `brd-25` Panzor the Invincible [R]
- [ ] `brd-26` Hurley Blackbreath [E]
- [ ] `brd-27` Ribbly Screwspigot [Q, E]
- [ ] `brd-28` Plugger Spazzring [E]
- [ ] `brd-29` Phalanx [E]
- [ ] `brd-30` Ambassador Flamelash
- [ ] `brd-31` The Seven: Anger'rel, Doom'rel, Dope'rel, Gloom'rel, Hate'rel, Seeth'rel, Vile'rel [E, M]
- [ ] `brd-32` Magmus
- [ ] `brd-33` Emperor Dagran Thaurissan / Princess Moira Bronzebeard [M, V]

Ytterligare underlag: [Shadowforge City och The Seven](https://www.wowhead.com/classic/guide/blackrock-depths-shadowforge-city-dungeon-strategy-wow-classic), [Dark Keeper-varianter](https://www.wowhead.com/classic/npc=9439/dark-keeper-uggel).

Theldrens varierande följeslagare registreras inom arenakortet vid detaljgranskning. Princess Moira får egen NPC-identitet och relationstillstånd i kejsarmötet; hennes död är inte ett generellt krav för seger. Grim Guzzler behöver hålla isär de olika aktiveringarna och när NPC:er blir fientliga.

## 19. Lower Blackrock Spire

**Planeringsfokus:** Separera huvudvägen, rares och frambesvärjningar; flera namngivna fiender kan tillhöra samma strid.

Underlag: [Era-guide för Lower Blackrock Spire](https://www.wowhead.com/classic/guide/lower-blackrock-spire-lbrs-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `lbrs-01` Highlord Omokk
- [ ] `lbrs-02` Shadow Hunter Vosh'gajin
- [ ] `lbrs-03` War Master Voone
- [ ] `lbrs-04` Mother Smolderweb
- [ ] `lbrs-05` Urok Doomhowl [E]
- [ ] `lbrs-06` Quartermaster Zigris
- [ ] `lbrs-07` Halycon / Gizrul the Slavener [M]
- [ ] `lbrs-08` Overlord Wyrmthalak
- [ ] `lbrs-09` Spirestone Butcher [R]
- [ ] `lbrs-10` Spirestone Battle Lord [R]
- [ ] `lbrs-11` Spirestone Lord Magus [R]
- [ ] `lbrs-12` Bannok Grimaxe [R]
- [ ] `lbrs-13` Crystal Fang [R]
- [ ] `lbrs-14` Ghok Bashguud [R]
- [ ] `lbrs-15` Burning Felguard [R, E]
- [ ] `lbrs-16` Mor Grayhoof [Q, E]

## 20. Upper Blackrock Spire

**Planeringsfokus:** Arenavågorna och Gyth/Rend hör samman. Stöd och gruppbeteende måste provas för UBRS särskilt.

Underlag: [Era-guide för Upper Blackrock Spire](https://www.wowhead.com/classic/guide/upper-blackrock-spire-ubrs-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `ubrs-01` Pyroguard Emberseer [E]
- [ ] `ubrs-02` Solakar Flamewreath [E]
- [ ] `ubrs-03` Goraluk Anvilcrack [Q]
- [ ] `ubrs-04` Jed Runewatcher [R]
- [ ] `ubrs-05` Gyth / Warchief Rend Blackhand [E, M]
- [ ] `ubrs-06` The Beast
- [ ] `ubrs-07` General Drakkisath
- [ ] `ubrs-08` Lord Valthalak [Q, E]

## 21. Dire Maul – East

**Planeringsfokus:** Pusillins steg, satyrerna och de andra invånarna får skilda motiv och tillfällen.

Underlag: [Era-guide för Dire Maul – East](https://www.wowhead.com/classic/guide/dire-maul-east-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `dm-east-01` Pusillin [E]
- [ ] `dm-east-02` Lethtendris / Pimgib [M]
- [ ] `dm-east-03` Hydrospawn
- [ ] `dm-east-04` Zevrim Thornhoof
- [ ] `dm-east-05` Alzzin the Wildshaper

## 22. Dire Maul – West

**Planeringsfokus:** Pyloner, Immol'thar och prinsens möte behöver korrekt ordning och slutvillkor.

Underlag: [Era-guide för Dire Maul – West](https://www.wowhead.com/classic/guide/dire-maul-west-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `dm-west-01` Tendris Warpwood
- [ ] `dm-west-02` Illyanna Ravenoak / Ferra [M]
- [ ] `dm-west-03` Magister Kalendris
- [ ] `dm-west-04` Tsu'zee [R]
- [ ] `dm-west-05` Immol'thar
- [ ] `dm-west-06` Prince Tortheldrin
- [ ] `dm-west-07` Xorothian Dreadsteed / Lord Hel'nurath [Q, E, M]

## 23. Dire Maul – North

**Planeringsfokus:** Vanlig rensning och tribute får olika avslut. Att lämna en vakt eller Cho'Rush vid liv är inte automatiskt ett ofärdigt möte.

Underlag: [Era-guide för Dire Maul – North](https://www.wowhead.com/classic/guide/dire-maul-north-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `dm-north-01` Guard Mol'dar
- [ ] `dm-north-02` Stomper Kreeg [V]
- [ ] `dm-north-03` Guard Fengus
- [ ] `dm-north-04` Guard Slip'kik
- [ ] `dm-north-05` Captain Kromcrush
- [ ] `dm-north-06` King Gordok / Cho'Rush the Observer [M, V]

Tribute knyter ihop vakterna, fällan, eventuell förklädnad och slutmötet. Ett kosmetiskt hån får aldrig fungera som en order att dra en grupp eller döda en sparad NPC.

## 24. Scholomance

**Planeringsfokus:** Skolans lärare, Barovfamiljen och questmötena får individuella kort och olika ton.

Underlag: [Era-guide för Scholomance](https://www.wowhead.com/classic/guide/scholomance-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `scholomance-01` Blood Steward of Kirtonos [V]
- [ ] `scholomance-02` Kirtonos the Herald [E]
- [ ] `scholomance-03` Jandice Barov
- [ ] `scholomance-04` Rattlegore
- [ ] `scholomance-05` Death Knight Darkreaver [Q, E]
- [ ] `scholomance-06` Marduk Blackpool
- [ ] `scholomance-07` Vectus
- [ ] `scholomance-08` Ras Frostwhisper
- [ ] `scholomance-09` Kormok [Q, E]
- [ ] `scholomance-10` Instructor Malicia
- [ ] `scholomance-11` Doctor Theolen Krastinov
- [ ] `scholomance-12` Lorekeeper Polkelt
- [ ] `scholomance-13` The Ravenian
- [ ] `scholomance-14` Lord Alexei Barov
- [ ] `scholomance-15` Lady Illucia Barov
- [ ] `scholomance-16` Darkmaster Gandling

## 25. Stratholme – Live / Scarlet

**Planeringsfokus:** Gemensamma stadsmöten registreras här en gång. Scarlet Bastion och Balnazzars avslöjande behöver egna steg.

Underlag: [Era-guide för Stratholme – Live / Scarlet](https://www.wowhead.com/classic/guide/stratholme-live-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `strat-live-01` Skul [R]
- [ ] `strat-live-02` Stratholme Courier [E, V]
- [ ] `strat-live-03` Postmaster Malown [E]
- [ ] `strat-live-04` Hearthsinger Forresten [R]
- [ ] `strat-live-05` The Unforgiven [E]
- [ ] `strat-live-06` Timmy the Cruel
- [ ] `strat-live-07` Crimson Hammersmith [E, V]
- [ ] `strat-live-08` Ezra Grimm (äldre namn: Fras Siabi) [Q, E]
- [ ] `strat-live-09` Cannon Master Willey
- [ ] `strat-live-10` Archivist Galford
- [ ] `strat-live-11` Grand Crusader Dathrohan / Balnazzar [M]
- [ ] `strat-live-12` Jarien / Sothos [Q, E, M]
- [ ] `strat-live-13` Malor the Zealous [Q, V]

Namnkontroll: [Ezra Grimm, NPC 11058](https://www.wowhead.com/classic/npc=11058/ezra-grimm), är samma identitet som äldre källors Fras Siabi och ska inte bli två kort. Senare expansionslore i en databasbeskrivning används inte som Era-lore, även om sidans adress innehåller Classic.

## 26. Stratholme – Undead / Scourge

**Planeringsfokus:** Ziggurater, gauntlet och Rivendare får separata steg; inga dubbla reaktioner för stadsmötena ovan.

Underlag: [Era-guide för Stratholme – Undead / Scourge](https://www.wowhead.com/classic/guide/stratholme-undead-dungeon-strategy-wow-classic). Fokus och framtida emoteval är våra designförslag.

- [ ] `strat-undead-01` Magistrate Barthilas
- [ ] `strat-undead-02` Baroness Anastari
- [ ] `strat-undead-03` Nerub'enkan
- [ ] `strat-undead-04` Maleki the Pallid
- [ ] `strat-undead-05` Stonespine [R]
- [ ] `strat-undead-06` Ramstein the Gorger [E]
- [ ] `strat-undead-07` Baron Rivendare
- [ ] `strat-undead-08` Black Guard Swordsmith [E, V]

Kompletterande underlag: [Black Guard Swordsmith](https://www.wowhead.com/classic/npc=11121/black-guard-swordsmith).

Black Guard Sentries efter Ramstein ingår i mötets efterspel. Gemensamma NPC:er från stadens första del refererar till samma identiteter som i Live-avsnittet.

## Kompletterande dungeonhändelser

Dessa får scenkort kopplade till respektive dungeon. De är inte ytterligare bossar och ingår inte i kortantalet ovan.

| Dungeon | Händelse att utforma och kontrollera |
|---|---|
| Wailing Caverns | Disciple of Naralex-eskorten och ritualen |
| Deadmines | Kanonen/dörren och övergången till skeppsområdet |
| Shadowfang Keep | Befrielse av fången och öppning av vägen vidare |
| Blackfathom Deeps | De fyra eldarna och deras vågor |
| Gnomeregan | Blastmaster Emi Shortfuse och sprängningarna; separat bedömning av eskorter |
| Razorfen Kraul | Willix the Importer-eskorten |
| Razorfen Downs | Belnistrasz ritual och Tuten'kash-gongen |
| Uldaman | Statyer, altaren och väckta väktare |
| Zul'Farrak | Fångarna, pyramidvågorna, Weegli och gongmötet |
| Maraudon | Celebras-förloppet och de fem khanernas quest |
| Sunken Temple | Statyordning, barriär och Hakkar-ritual |
| Blackrock Depths | Ring of Law, valvet, krogen, The Seven och Lyceum |
| Lower Blackrock Spire | Urok-eventet |
| Upper Blackrock Spire | Emberseer, ägg-eventet och arenavågorna |
| Dire Maul East | Pusillins jakt och Old Ironbark |
| Dire Maul West | Pylonerna och Dreadsteed-eventet |
| Dire Maul North | Fällan, förklädnaden och tribute-resultatet |
| Scholomance | Klassquestevent och Gandlings mötesförlopp |
| Stratholme | Postlådorna, zigguraterna, gauntlet och Ysida-förloppet |

Befintliga voice-emotes och gester väljs först när den konkreta scenen kan bekräftas. Ingen egen dialog skapas för eventen.

## Villkorad reserv: ursprungliga Scourge Invasion

Dessa är historiskt Classic-innehåll men **räknas inte som vanliga, aktuellt tillgängliga Hardcore-möten**. De hålls utanför huvudlistans kortantal. Serverns faktiska eventtillgänglighet behöver verifieras innan något sådant kort tas vidare.

| Dungeon | Event-NPC |
|---|---|
| Shadowfang Keep | Sever |
| Scarlet Monastery Graveyard | Scorn |
| Razorfen Downs | Lady Falther'ess |
| Dire Maul West | Revanchion |
| Scholomance | Lord Blackwood |
| Stratholme Live | Balzaphon |

Underlag: [Scourge Invasions i ursprungliga WoW Classic](https://www.wowhead.com/classic/guide/wow-classic-scourge-invasions). Senare återanvändning av samma namn är inte grund för att lägga till senare mekaniker.

## Täckning och kvarvarande arbete

- Samtliga vanliga Era-dungeons finns som planeringsavsnitt; vingar och rutter har delats för läsbarhet.
- Rares, questmöten, flerfasiga möten och relevanta namngivna minibossar finns med i arbetslistan.
- Namngivna fiender i öppna entréområden, utöver de uttryckligen inkluderade questkopplingarna, ingår i ett eventuellt senare paket för världen utanför dungeons.
- Varje kort behöver fortfarande exakt identitet, granskad lore, valda standardemotes och bekräftade triggers.
- Källorna är innehållsunderlag, inte bevis för att HCVoice kan detektera händelserna eller spela upp en viss röst.
- Markera ett kort färdigt först när kriterierna i planen är uppfyllda, inklusive speltest.
