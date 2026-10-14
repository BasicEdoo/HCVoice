# Implementerade bossreaktioner – HCVoice 1.7.0

Genererad från `Bosses/Content.lua`. 230 möteskort i 26 dungeon-/vingavsnitt. Varje kort har egna val och en motivering. Samma standardemote kan passa flera bossar; detta är inte 230 nya röster.

## Så läser du listan

- **Mål/pull:** öppningen kan försökas efter 1,5 sekunders avsiktligt målval utanför strid, annars vid gruppens första observerade strid med bossen.
- **Pull:** öppningen kräver verklig strid. För båda varianterna måste din karaktär fortfarande ha rätt, fientlig boss som target.
- **Efter:** bekräftade dödsfall enligt mötets slutvillkor och minst fyra sekunder utan gruppstrid. Herod och Ramstein väntar minst tolv sekunder.
- Tillfället hoppas över vid fara, sorg, casting, channeling, kontrollförlust, klientspärr eller otillräckligt utrymme mellan emotes. En öppning är inte garanterad vid varje pull; befintliga INCOMING/HEALME/FLEE har företräde.
- Minst tolv sekunder mellan kosmetiska bossreaktioner. Öppningar/fasreaktioner förfaller efter tre sekunder. Inga boss-popups eller egna repliker skickas.
- Motiveringarna är våra RP-tolkningar, inte citat eller repliker ur spelet. NPC-identiteter är uppslagna i den installerade Questie-databasen för Classic; HCVoice behöver inte Questie när det körs. Lore- och möteskällor finns per dungeon i bosskatalogen.
- **Status:** implementerat och simulerat. Hörbar röst, animation, verklig stridstajming och varje mötes signaler återstår att bekräfta i spelklienten. Standardemotes kan ge Blizzards vanliga emoterad.

## Särskilda mötesregler

| Möte | Observerad signal och regel |
|---|---|
| Sneed | GASP när piloten först deltar efter shreddern. Båda måste besegras. |
| Mr. Smite | GASP när spelarens Smite Stomp-aura (6432) faktiskt tas bort. Ingen uppskattad stuntimer. |
| Mograine/Whitemane | GASP vid Scarlet Resurrection (9232). Mograine räknas åter som levande; båda måste besegras. |
| Halycon/Gizrul | GASP när Gizrul deltar. Båda måste besegras. |
| Gyth/Rend | ROAR när Rend deltar. Båda måste besegras. |
| Dreadsteed/Hel'nurath | GASP när Hel'nurath deltar. Båda måste besegras. |
| Dathrohan/Balnazzar | GASP när Balnazzar identifieras i striden. Dathrohans form räcker inte som slutbevis. |
| Thaurissan/Moira | Bara kejsarens död krävs. Moira behöver inte dö. |
| Gordok/Cho'Rush | Bara kungens död krävs. Inget påstående om en fullständig tribute-run utifrån detta. |
| Maraudons khaner | Varje khan är ett eget möte, även de tre i de yttre grottorna. |
| Övriga grupperade kort | Alla listade NPC-ID:n måste ha observerats i strid och dött. |

Fasreaktioner kräver ett redan observerat möte. Högst två signaturreaktioner per möte, högst en per definierad signal. Saknade signaler, reset och despawn skapar ingen seger.

## Ragefire Chasm

Instance/map-ID: `389`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `rfc-01` Oggleflint | 11517 | Pull: `ROAR` | `VICTORY` | Stand up to the trogg leader guarding these caverns. |
| `rfc-02` Taragaman the Hungerer | 11520 | Pull: `GASP` | `SIGH` | A demon beneath Orgrimmar calls for alarm followed by relief. |
| `rfc-03` Jergosh the Invoker | 11518 | Mål/pull: `RASP` | `VICTORY` | Defy the Searing Blade invoker without encouraging a pull. |
| `rfc-04` Bazzalan | 11519 | Mål/pull: `RASP` | `CHEER` | Mock the cult's satyr leader only when he is an actual opponent. |

## Wailing Caverns

Instance/map-ID: `43`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `wc-01` Lady Anacondra | 3671 | Pull: `NO` | `SIGH` | Reject Anacondra's corrupted druidic path; end with relief. |
| `wc-02` Lord Cobrahn | 3669 | Pull: `ROAR` | `SIGH` | Answer Cobrahn's bestial presence with defiance. |
| `wc-03` Kresh | 3653 | Mål/pull: `BOW` | `SIGH` | Acknowledge the great turtle instead of insulting an ordinary beast. |
| `wc-04` Lord Pythas | 3670 | Pull: `NO` | `SIGH` | Oppose Pythas as a corrupted druid rather than a comic villain. |
| `wc-05` Skum | 3674 | Pull: `GASP` | `SIGH` | React to the cavern thunder lizard without a tactical order. |
| `wc-06` Lord Serpentis | 3673 | Pull: `ROAR` | `VICTORY` | Challenge the leader of the Druids of the Fang. |
| `wc-07` Verdan the Everliving | 5775 | Pull: `GASP` | `SIGH` | The towering guardian warrants awe rather than ridicule. |
| `wc-08` Mutanus the Devourer | 3654 | Pull: `GASP` | `CHEER` | Mutanus is the ritual's final threat, not its opening wave. |
| `wc-09` Deviate Faerie Dragon | 5912 | Pull: `GASP` | `BOW` | Treat the unusual faerie dragon as a remarkable creature. |

## The Deadmines

Instance/map-ID: `36`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `deadmines-01` Rhahk'Zor | 644 | Pull: `ROAR` | `VICTORY` | Meet the mine's ogre enforcer with physical defiance. |
| `deadmines-02` Miner Johnson | 3586 | Pull: `NOD` | `VICTORY` | Acknowledge the rare foreman before confronting him. |
| `deadmines-03` Sneed's Shredder / Sneed | 642,643 | Mål/pull: `RASP` | `CHEER` | Mock the machine; victory waits for the pilot as well. |
| `deadmines-04` Gilnid | 1763 | Mål/pull: `RASP` | `VICTORY` | Taunt the goblin foundry master rather than the workers. |
| `deadmines-05` Mr. Smite | 646 | Mål/pull: `RASP` | `SIGH` | Challenge the ship's enforcer; respect his weapon-changing fight. |
| `deadmines-06` Captain Greenskin | 647 | Mål/pull: `SALUTE` | `VICTORY` | A pointed salute fits the pirate captain. |
| `deadmines-07` Cookie | 645 | Pull: `LAUGH` | `APPLAUD` | The murloc cook is a rare light-hearted opponent, only while safe. |
| `deadmines-08` Edwin VanCleef | 639 | Mål/pull: `RASP` | `VICTORY` | Defy the Defias leader without inventing a verdict on his history. |

## Shadowfang Keep

Instance/map-ID: `33`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `sfk-01` Rethilgore | 3914 | Mål/pull: `RASP` | `VICTORY` | Confront the jailer as an oppressor of the prisoners. |
| `sfk-02` Razorclaw the Butcher | 3886 | Pull: `GASP` | `SIGH` | The worgen butcher prompts unease rather than culinary jokes. |
| `sfk-03` Baron Silverlaine | 3887 | Mål/pull: `BOW` | `BOW` | Respect the spectral lord of the fallen keep. |
| `sfk-04` Commander Springvale | 4278 | Mål/pull: `SALUTE` | `BOW` | Acknowledge the dead commander with a restrained military gesture. |
| `sfk-05` Odo the Blindwatcher | 4279 | Pull: `ROAR` | `SIGH` | Confront the worgen watcher without mocking disability. |
| `sfk-06` Deathsworn Captain | 3872 | Mål/pull: `SALUTE` | `BOW` | Give the fallen captain a solemn acknowledgement. |
| `sfk-07` Fenrus the Devourer | 4274 | Pull: `GASP` | `SIGH` | Arugal's great beast inspires surprise followed by relief. |
| `sfk-08` Wolf Master Nandos | 3927 | Mål/pull: `RASP` | `VICTORY` | Direct defiance at the wolf master rather than his animals. |
| `sfk-09` Archmage Arugal | 4275 | Mål/pull: `RASP` | `SIGH` | Defy Arugal; finishing his haunted keep calls for relief. |

## The Stockade

Instance/map-ID: `34`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `stockade-01` Targorr the Dread | 1696 | Pull: `ROAR` | `VICTORY` | Meet the violent prisoner with defiance. |
| `stockade-02` Kam Deepfury | 1666 | Mål/pull: `RASP` | `VICTORY` | Challenge Deepfury as a named participant in the uprising. |
| `stockade-03` Hamhock | 1717 | Pull: `GASP` | `SIGH` | The ogre among the prisoners is a striking confrontation. |
| `stockade-04` Dextren Ward | 1663 | Pull: `NO` | `SIGH` | Reject Ward's intimidation without adding a second fear warning. |
| `stockade-05` Bazil Thredd | 1716 | Mål/pull: `RASP` | `VICTORY` | Defy the revolt's leader rather than issue general jailhouse jokes. |
| `stockade-06` Bruegal Ironknuckle | 1720 | Pull: `NOD` | `VICTORY` | Acknowledge the rare brawler and keep the gesture brief. |

## Blackfathom Deeps

Instance/map-ID: `48`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `bfd-01` Ghamoo-ra | 4887 | Pull: `GASP` | `BOW` | The great turtle deserves awe rather than a human insult. |
| `bfd-02` Lady Sarevess | 4831 | Mål/pull: `RASP` | `VICTORY` | Defy the naga lady occupying the drowned temple. |
| `bfd-03` Gelihast | 6243 | Pull: `ROAR` | `VICTORY` | Answer the murloc's aggressive presence with a gesture. |
| `bfd-04` Lorgus Jett | 12902 | Pull: `NO` | `VICTORY` | Oppose Jett when hostile, not merely when his name is seen. |
| `bfd-05` Baron Aquanis | 12876 | Pull: `GASP` | `SIGH` | The summoned water elemental is an unexpected guardian. |
| `bfd-06` Old Serra'kis | 4830 | Pull: `GASP` | `SIGH` | The submerged beast warrants unease and quiet relief. |
| `bfd-07` Twilight Lord Kelris | 4832 | Mål/pull: `RASP` | `VICTORY` | Defy the Twilight's Hammer leader before the temple event. |
| `bfd-08` Aku'mai | 4829 | Pull: `GASP` | `CHEER` | The cult's great hydra is the culmination of the dungeon. |

## Gnomeregan

Instance/map-ID: `90`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `gnomeregan-01` Grubbis / Chomper | 7361,6215 | Pull: `GASP` | `CHEER` | The cave event ends only after Grubbis and his companion. |
| `gnomeregan-02` Viscous Fallout | 7079 | Pull: `GASP` | `SIGH` | Respond to living contamination without joking about the city's loss. |
| `gnomeregan-03` Electrocutioner 6000 | 6235 | Mål/pull: `RASP` | `VICTORY` | A mechanical opponent suits a short defiant gesture. |
| `gnomeregan-04` Crowd Pummeler 9-60 | 6229 | Pull: `ROAR` | `VICTORY` | Match the pummeling machine with physical defiance. |
| `gnomeregan-05` Dark Iron Ambassador | 6228 | Pull: `NO` | `VICTORY` | Reject the Dark Iron presence in the ruined city. |
| `gnomeregan-06` Mekgineer Thermaplugg | 7800 | Mål/pull: `RASP` | `VICTORY` | Confront Thermaplugg as the final mechanical tyrant. |

## Razorfen Kraul

Instance/map-ID: `47`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `rfk-01` Roogug | 6168 | Pull: `NO` | `SIGH` | Face the quest's shaman without treating the whole dungeon as his fight. |
| `rfk-02` Aggem Thorncurse | 4424 | Pull: `ROAR` | `VICTORY` | Answer Thorncurse's quilboar leadership with defiance. |
| `rfk-03` Death Speaker Jargba | 4428 | Pull: `NO` | `SIGH` | Reject the Death Speaker's domination rather than ridicule its victim. |
| `rfk-04` Overlord Ramtusk | 4420 | Mål/pull: `RASP` | `VICTORY` | Taunt the overlord, not the surrounding captive creatures. |
| `rfk-05` Agathelos the Raging | 4422 | Pull: `GASP` | `SIGH` | The enormous raging boar calls for awe followed by relief. |
| `rfk-06` Blind Hunter | 4425 | Pull: `GASP` | `BOW` | Acknowledge the rare bat without a pet-taming implication. |
| `rfk-07` Earthcaller Halmgar | 4842 | Pull: `GASP` | `SIGH` | A summoned elemental makes Halmgar's encounter distinctive. |
| `rfk-08` Charlga Razorflank | 4421 | Mål/pull: `RASP` | `VICTORY` | Defy Razorflank as the dungeon's quilboar leader. |
| `rfk-09` Razorfen Spearhide | 4438 | Pull: `ROAR` | `VICTORY` | Meet the rare quilboar fighter with a single matching gesture. |

## Scarlet Monastery – Graveyard

Instance/map-ID: `189`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `sm-graveyard-01` Interrogator Vishas | 3983 | Pull: `NO` | `VICTORY` | Refuse the interrogator's cruelty with a direct gesture. |
| `sm-graveyard-02` Bloodmage Thalnos | 4543 | Pull: `GASP` | `SIGH` | The bloodmage in the crypt merits unease. |
| `sm-graveyard-03` Azshir the Sleepless | 6490 | Pull: `GASP` | `BOW` | The restless spirit receives a solemn conclusion. |
| `sm-graveyard-04` Fallen Champion | 6488 | Mål/pull: `SALUTE` | `BOW` | A fallen champion is acknowledged rather than laughed at. |
| `sm-graveyard-05` Ironspine | 6489 | Pull: `GASP` | `SIGH` | The graveyard horror calls for relief on survival. |

## Scarlet Monastery – Library

Instance/map-ID: `189`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `sm-library-01` Houndmaster Loksey | 3974 | Mål/pull: `RASP` | `VICTORY` | Defiance is aimed at the houndmaster, not at his hounds. |
| `sm-library-02` Arcanist Doan | 6487 | Mål/pull: `RASP` | `SIGH` | Challenge Doan's arcane confidence with a restrained ending. |

## Scarlet Monastery – Armory

Instance/map-ID: `189`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `sm-armory-01` Herod | 3975 | Mål/pull: `RASP` | `VICTORY` | Answer the Scarlet champion's bravado; respect his aftermath. |

## Scarlet Monastery – Cathedral

Instance/map-ID: `189`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `sm-cathedral-01` High Inquisitor Fairbanks | 4542 | Pull: `GASP` | `BOW` | Fairbanks' hidden condition calls for restraint rather than triumph. |
| `sm-cathedral-02` Scarlet Commander Mograine / High Inquisitor Whitemane | 3976,3977 | Mål/pull: `RASP` | `CHEER` | Challenge the Scarlet leadership; resurrection is not victory. |

## Razorfen Downs

Instance/map-ID: `129`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `rfd-01` Tuten'kash | 7355 | Pull: `GASP` | `SIGH` | The gong releases a large crypt creature. |
| `rfd-02` Mordresh Fire Eye | 7357 | Pull: `NO` | `VICTORY` | Reject the skeletal caster's display over the bone pile. |
| `rfd-03` Glutton | 8567 | Pull: `GASP` | `SIGH` | The diseased brute is a threat, not an invitation to food jokes. |
| `rfd-04` Ragglesnout | 7354 | Pull: `GASP` | `SIGH` | The rare quilboar caster calls for cautious relief. |
| `rfd-05` Amnennar the Coldbringer | 7358 | Mål/pull: `RASP` | `VICTORY` | Defy the lich controlling the Downs. |
| `rfd-06` Plaguemaw the Rotting | 7356 | Pull: `GASP` | `CHEER` | The ritual's final enemy deserves a conclusion only after combat. |

## Uldaman

Instance/map-ID: `70`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `uldaman-01` Revelosh | 6910 | Mål/pull: `RASP` | `VICTORY` | Challenge the trogg holding a piece of the temple key. |
| `uldaman-02` The Lost Dwarves: Baelog, Eric "The Swift", Olaf | 6906,6907,6908 | Mål/pull: `SALUTE` | `BOW` | Respect the three dwarves; react only if actually hostile. |
| `uldaman-03` Ironaya | 7228 | Pull: `GASP` | `BOW` | The awakened stone guardian inspires awe and respect. |
| `uldaman-04` Obsidian Sentinel | 7023 | Pull: `GASP` | `SIGH` | The obsidian construct is a formidable sentinel. |
| `uldaman-05` Ancient Stone Keeper | 7206 | Mål/pull: `BOW` | `BOW` | Acknowledge an ancient guardian rather than mock its duty. |
| `uldaman-06` Galgann Firehammer | 7291 | Pull: `NO` | `VICTORY` | Oppose the Dark Iron expedition's commander. |
| `uldaman-07` Grimlok | 4854 | Pull: `ROAR` | `VICTORY` | Answer the trogg leader's primitive strength. |
| `uldaman-08` Archaedas | 2748 | Pull: `GASP` | `BOW` | An awakened ancient keeper deserves a restrained conclusion. |

## Zul'Farrak

Instance/map-ID: `209`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `zf-01` Antu'sul | 8127 | Pull: `RASP` | `SIGH` | Challenge the overseer without treating every summoned beast as a boss. |
| `zf-02` Theka the Martyr | 7272 | Pull: `NO` | `SIGH` | Reject the martyr's hostile magic, without invented theology. |
| `zf-03` Witch Doctor Zum'rah | 7271 | Pull: `RASP` | `SIGH` | Defy the witch doctor raising threats among the graves. |
| `zf-04` Sandfury Executioner | 7274 | Pull: `NO` | `VICTORY` | Confront the executioner before the prisoners' event. |
| `zf-05` Nekrum Gutchewer / Shadowpriest Sezz'ziz | 7796,7275 | Pull: `GASP` | `CHEER` | The pyramid's final pair requires both deaths. |
| `zf-06` Sergeant Bly och hans grupp | 7604,7605,7606,7608 | Pull: `NO` | `SIGH` | Only react to the prisoners when an actual hostile confrontation begins. |
| `zf-07` Hydromancer Velratha | 7795 | Pull: `RASP` | `VICTORY` | Defy the hydromancer at the sacred pool. |
| `zf-08` Chief Ukorz Sandscalp / Ruuzlu | 7267,7797 | Pull: `ROAR` | `VICTORY` | Confront the chief and his companion as one meeting. |
| `zf-09` Gahz'rilla | 7273 | Pull: `GASP` | `CHEER` | The gong's great hydra warrants awe and a distinct final celebration. |
| `zf-10` Zerillis | 10082 | Pull: `GASP` | `VICTORY` | Acknowledge the rare patrol when it actually engages the group. |
| `zf-11` Sandarr Dunereaver | 10080 | Pull: `ROAR` | `VICTORY` | Answer the rare desert fighter with defiance. |
| `zf-12` Dustwraith | 10081 | Pull: `GASP` | `SIGH` | A rare apparition in the sand warrants an uneasy reaction. |

## Maraudon

Instance/map-ID: `349`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `maraudon-01` Noxxion | 13282 | Pull: `GASP` | `SIGH` | The living poison in the orange caves merits relief, not applause. |
| `maraudon-02` Razorlash | 12258 | Pull: `ROAR` | `SIGH` | Confront the hostile plant without a human insult. |
| `maraudon-03` Lord Vyletongue | 12236 | Mål/pull: `RASP` | `VICTORY` | Defy the satyr lord in the purple caves. |
| `maraudon-04` Meshlok the Harvester | 12237 | Pull: `GASP` | `BOW` | Acknowledge the rare corrupted tree with restraint. |
| `maraudon-05` Celebras the Cursed | 12225 | Pull: `NO` | `BOW` | The cursed druid's defeat calls for respect rather than humiliation. |
| `maraudon-06` Landslide | 12203 | Pull: `GASP` | `SIGH` | The great rock elemental inspires awe. |
| `maraudon-07` Tinkerer Gizlock | 13601 | Mål/pull: `RASP` | `APPLAUD` | A playful challenge suits the goblin tinker's machinery. |
| `maraudon-08` Rotgrip | 13596 | Pull: `GASP` | `SIGH` | The cavern crocodile is an animal threat, not a villainous mastermind. |
| `maraudon-09` Princess Theradras | 12201 | Pull: `GASP` | `SIGH` | The earth princess warrants awe; do not invent claims about Zaetar. |
| `maraudon-10` De fem khanerna: Kolk, Gelk, Magra, Maraudos, Veng | 13742,13741,13740,13739,13738 | Mål/pull: `BOW` | `BOW` | Each khan is an ancestral spirit, treated separately and respectfully. |

## The Temple of Atal'Hakkar / Sunken Temple

Instance/map-ID: `109`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `st-01` Atal'alarion | 8580 | Pull: `GASP` | `VICTORY` | The statue ritual wakes this guardian, not a random patrol. |
| `st-02` Gasher | 5713 | Pull: `ROAR` | `VICTORY` | Gasher receives a brief physical challenge as a troll guardian. |
| `st-03` Hukku | 5715 | Pull: `NO` | `VICTORY` | Reject Hukku's hostile ritual role. |
| `st-04` Loro | 5714 | Pull: `NOD` | `VICTORY` | Acknowledge Loro as one of the six barriers' guardians. |
| `st-05` Mijan | 5717 | Pull: `NO` | `SIGH` | Reject Mijan's hostile magic with a restrained ending. |
| `st-06` Zolo | 5712 | Mål/pull: `RASP` | `VICTORY` | Defy Zolo as a distinct temple guardian. |
| `st-07` Zul'Lor | 5716 | Pull: `ROAR` | `VICTORY` | Meet Zul'Lor's martial role with a gesture. |
| `st-08` Jammal'an the Prophet / Ogom the Wretched | 5710,5711 | Mål/pull: `RASP` | `VICTORY` | Confront the prophet and his companion as one encounter. |
| `st-09` Dreamscythe | 5721 | Pull: `GASP` | `BOW` | The corrupted green dragon warrants awe and a solemn finish. |
| `st-10` Weaver | 5720 | Pull: `GASP` | `BOW` | Treat Weaver as a dragon rather than a target for generic jokes. |
| `st-11` Morphaz / Hazzas | 5719,5722 | Pull: `GASP` | `BOW` | The dragon pair shares one respectful conclusion. |
| `st-12` Avatar of Hakkar | 8443 | Pull: `NO` | `VICTORY` | Reject the summoned blood god's avatar, not the full deity. |
| `st-13` Shade of Eranikus | 5709 | Pull: `GASP` | `BOW` | Eranikus' shade is a tragic corrupted guardian, not comic prey. |

## Blackrock Depths

Instance/map-ID: `230`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `brd-01` Lord Roccor | 9025 | Pull: `GASP` | `SIGH` | The rock elemental at the entrance invites awe. |
| `brd-02` High Interrogator Gerstahn | 9018 | Pull: `NO` | `VICTORY` | Reject Gerstahn's interrogation rather than mock prisoners. |
| `brd-03` Houndmaster Grebmar | 9319 | Pull: `RASP` | `VICTORY` | Aim defiance at Grebmar, not the hounds. |
| `brd-04` Bael'Gar | 9016 | Pull: `GASP` | `SIGH` | The towering fire giant warrants a cautious response. |
| `brd-05` Pyromancer Loregrain | 9024 | Pull: `RASP` | `VICTORY` | Defy the pyromancer's control of fire. |
| `brd-06` Gorosh the Dervish | 9027 | Pull: `ROAR` | `VICTORY` | Meet the arena's dervish with a martial gesture. |
| `brd-07` Grizzle | 9028 | Pull: `GASP` | `SIGH` | The arena bear is a beast rather than a criminal. |
| `brd-08` Eviscerator | 9029 | Pull: `GASP` | `SIGH` | The arena's razor-beaked creature warrants unease. |
| `brd-09` Ok'thor the Breaker | 9030 | Pull: `RASP` | `VICTORY` | Challenge the ogre spellcaster in the arena. |
| `brd-10` Anub'shiah | 9031 | Pull: `NO` | `SIGH` | Reject the arena opponent's shadow magic. |
| `brd-11` Hedrum the Creeper | 9032 | Pull: `GASP` | `SIGH` | The arena spider merits relief rather than ridicule. |
| `brd-12` Theldren och arenagruppen | 16059 | Pull: `SALUTE` | `VICTORY` | Acknowledge the rival arena team before contesting it. |
| `brd-13` Lord Incendius | 9017 | Pull: `GASP` | `VICTORY` | The fire elemental guarding the anvil merits a defiant finish. |
| `brd-14` Fineous Darkvire | 9056 | Pull: `RASP` | `VICTORY` | Confront the architect as an individual obstacle. |
| `brd-15` Warder Stilgiss / Verek | 9041,9042 | Pull: `NO` | `VICTORY` | The vault keeper and hound must be resolved together. |
| `brd-16` Watchman Doomgrip | 9476 | Pull: `GASP` | `SIGH` | The vault's activated security is an unexpected threat. |
| `brd-17` Dark Keeper Bethek | 9438 | Pull: `NOD` | `VICTORY` | Acknowledge Bethek as the identified keeper of the vault key. |
| `brd-18` Dark Keeper Ofgut | 9442 | Pull: `NOD` | `VICTORY` | Acknowledge Ofgut as the identified keeper of the vault key. |
| `brd-19` Dark Keeper Pelver | 9443 | Pull: `NOD` | `VICTORY` | Acknowledge Pelver as the identified keeper of the vault key. |
| `brd-20` Dark Keeper Uggel | 9439 | Pull: `NOD` | `VICTORY` | Acknowledge Uggel as the identified keeper of the vault key. |
| `brd-21` Dark Keeper Vorfalk | 9437 | Pull: `NOD` | `VICTORY` | Acknowledge Vorfalk as the identified keeper of the vault key. |
| `brd-22` Dark Keeper Zimrel | 9441 | Pull: `NOD` | `VICTORY` | Acknowledge Zimrel as the identified keeper of the vault key. |
| `brd-23` General Angerforge | 9033 | Pull: `SALUTE` | `VICTORY` | A defiant military salute fits Angerforge's command. |
| `brd-24` Golem Lord Argelmach | 8983 | Pull: `RASP` | `VICTORY` | Mock the golem master once rather than each machine. |
| `brd-25` Panzor the Invincible | 8923 | Pull: `ROAR` | `VICTORY` | Answer the construct's claim to invincibility with defiance. |
| `brd-26` Hurley Blackbreath | 9537 | Pull: `GASP` | `SIGH` | The bar brawl must actually start before any reaction. |
| `brd-27` Ribbly Screwspigot | 9543 | Pull: `NO` | `SIGH` | React to Ribbly's hostile confrontation, not peaceful tavern company. |
| `brd-28` Plugger Spazzring | 9499 | Pull: `NO` | `SIGH` | Do not taunt a neutral bartender; only reject his hostility. |
| `brd-29` Phalanx | 9502 | Pull: `GASP` | `SIGH` | The tavern's security golem is not hostile by default. |
| `brd-30` Ambassador Flamelash | 9156 | Pull: `RASP` | `VICTORY` | Defy the fiery ambassador in his chamber. |
| `brd-31` The Seven: Anger'rel, Doom'rel, Dope'rel, Gloom'rel, Hate'rel, Seeth'rel, Vile'rel | 9035,9039,9040,9037,9034,9038,9036 | Pull: `SALUTE` | `BOW` | The seven ancestral spirits deserve one solemn conclusion. |
| `brd-32` Magmus | 9938 | Pull: `GASP` | `VICTORY` | The giant before the throne merits an imposing gesture. |
| `brd-33` Emperor Dagran Thaurissan / Princess Moira Bronzebeard | 9019,8929 | Pull: `RASP` | `VICTORY` | Defy the emperor; Moira's death is never required. |

## Lower Blackrock Spire

Instance/map-ID: `229`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `lbrs-01` Highlord Omokk | 9196 | Pull: `ROAR` | `VICTORY` | Meet Omokk's ogre leadership with physical defiance. |
| `lbrs-02` Shadow Hunter Vosh'gajin | 9236 | Pull: `NO` | `SIGH` | Reject the shadow hunter's hostile magic without mocking its victim. |
| `lbrs-03` War Master Voone | 9237 | Mål/pull: `SALUTE` | `VICTORY` | Give the war master a pointed martial acknowledgement. |
| `lbrs-04` Mother Smolderweb | 10596 | Pull: `GASP` | `SIGH` | The broodmother is a creature to fear rather than ridicule. |
| `lbrs-05` Urok Doomhowl | 10584 | Pull: `ROAR` | `VICTORY` | The summoned ogre receives a single challenge. |
| `lbrs-06` Quartermaster Zigris | 9736 | Mål/pull: `RASP` | `VICTORY` | Taunt the quartermaster as the keeper of Blackrock supplies. |
| `lbrs-07` Halycon / Gizrul the Slavener | 10220,10268 | Pull: `GASP` | `SIGH` | The two worgs belong to one encounter and one conclusion. |
| `lbrs-08` Overlord Wyrmthalak | 9568 | Pull: `ROAR` | `VICTORY` | Defy the dragonspawn overlord at the spire's lower end. |
| `lbrs-09` Spirestone Butcher | 9219 | Pull: `ROAR` | `VICTORY` | Confront the rare ogre butcher without generic food jokes. |
| `lbrs-10` Spirestone Battle Lord | 9218 | Mål/pull: `SALUTE` | `VICTORY` | A martial challenge suits the rare ogre battle lord. |
| `lbrs-11` Spirestone Lord Magus | 9217 | Pull: `NO` | `VICTORY` | Reject the rare ogre magus' hostile magic. |
| `lbrs-12` Bannok Grimaxe | 9596 | Mål/pull: `RASP` | `VICTORY` | Defy the rare Blackrock champion when encountered. |
| `lbrs-13` Crystal Fang | 10376 | Pull: `GASP` | `SIGH` | The rare spider is an unusual animal threat. |
| `lbrs-14` Ghok Bashguud | 9718 | Pull: `ROAR` | `VICTORY` | Meet the rare ogre fighter with a physical gesture. |
| `lbrs-15` Burning Felguard | 10263 | Pull: `GASP` | `SIGH` | A rare summoned demon calls for alarm then relief. |
| `lbrs-16` Mor Grayhoof | 16080 | Mål/pull: `BOW` | `BOW` | Treat the summoned druid's spirit as a tragic opponent. |

## Upper Blackrock Spire

Instance/map-ID: `229`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `ubrs-01` Pyroguard Emberseer | 9816 | Pull: `GASP` | `VICTORY` | The imprisoned fire elemental is a distinct release event. |
| `ubrs-02` Solakar Flamewreath | 10264 | Pull: `GASP` | `SIGH` | The rookery's defender marks the egg event's culmination. |
| `ubrs-03` Goraluk Anvilcrack | 10899 | Mål/pull: `RASP` | `VICTORY` | Confront Blackhand's armorer without a generic forge joke. |
| `ubrs-04` Jed Runewatcher | 10509 | Pull: `GASP` | `VICTORY` | Acknowledge the unusual runewatcher when actually found. |
| `ubrs-05` Gyth / Warchief Rend Blackhand | 10339,10429 | Pull: `ROAR` | `CHEER` | Rend and his mount share the arena's final encounter. |
| `ubrs-06` The Beast | 10430 | Pull: `GASP` | `SIGH` | A great core hound warrants awe instead of humanoid insults. |
| `ubrs-07` General Drakkisath | 10363 | Mål/pull: `SALUTE` | `VICTORY` | A defiant salute fits the dragonspawn general. |
| `ubrs-08` Lord Valthalak | 16042 | Pull: `NO` | `SIGH` | Face the summoned spirit with restraint and no invented absolution. |

## Dire Maul – East

Instance/map-ID: `429`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `dm-east-01` Pusillin | 14354 | Pull: `RASP` | `APPLAUD` | The trickster can be mocked once he finally turns hostile. |
| `dm-east-02` Lethtendris / Pimgib | 14327,14349 | Pull: `NO` | `VICTORY` | The warlock and imp share one hostile encounter. |
| `dm-east-03` Hydrospawn | 13280 | Pull: `GASP` | `SIGH` | The water elemental receives a visual response. |
| `dm-east-04` Zevrim Thornhoof | 11490 | Pull: `NO` | `VICTORY` | Reject the satyr's sacrificial ritual. |
| `dm-east-05` Alzzin the Wildshaper | 11492 | Pull: `ROAR` | `VICTORY` | Challenge the satyr wildshaper's corrupted forms. |

## Dire Maul – West

Instance/map-ID: `429`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `dm-west-01` Tendris Warpwood | 11489 | Pull: `GASP` | `BOW` | A corrupted ancient deserves respect after its defeat. |
| `dm-west-02` Illyanna Ravenoak / Ferra | 11488,14308 | Mål/pull: `SALUTE` | `BOW` | The fallen ranger and her companion receive a solemn finish. |
| `dm-west-03` Magister Kalendris | 11487 | Pull: `NO` | `BOW` | Oppose the spectral magister while acknowledging the ruin. |
| `dm-west-04` Tsu'zee | 11467 | Pull: `GASP` | `BOW` | The rare spirit should not be treated as comic prey. |
| `dm-west-05` Immol'thar | 11496 | Pull: `GASP` | `VICTORY` | The imprisoned demon is an imposing opponent. |
| `dm-west-06` Prince Tortheldrin | 11486 | Mål/pull: `RASP` | `VICTORY` | Defy the prince's arrogance without fabricating his words. |
| `dm-west-07` Xorothian Dreadsteed / Lord Hel'nurath | 14502,14506 | Pull: `GASP` | `CHEER` | The dreadsteed ritual concludes only after horse and rider. |

## Dire Maul – North

Instance/map-ID: `429`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `dm-north-01` Guard Mol'dar | 14326 | Pull: `ROAR` | `VICTORY` | Confront Mol'dar only if the group actually fights him. |
| `dm-north-02` Stomper Kreeg | 14322 | Pull: `LAUGH` | `SIGH` | A light-hearted response to Kreeg only during a real hostile encounter. |
| `dm-north-03` Guard Fengus | 14321 | Pull: `RASP` | `VICTORY` | Challenge Fengus only if he is not being bypassed. |
| `dm-north-04` Guard Slip'kik | 14323 | Pull: `RASP` | `VICTORY` | Challenge Slip'kik only in combat, never merely for being trapped. |
| `dm-north-05` Captain Kromcrush | 14325 | Pull: `SALUTE` | `VICTORY` | A pointed salute suits the ogre captain. |
| `dm-north-06` King Gordok / Cho'Rush the Observer | 11501,14324 | Pull: `ROAR` | `CHEER` | Challenge Gordok; the observer can survive the king's defeat. |

## Scholomance

Instance/map-ID: `289`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `scholomance-01` Blood Steward of Kirtonos | 14861 | Pull: `NO` | `SIGH` | Reject the blood steward's role without treating her as Kirtonos. |
| `scholomance-02` Kirtonos the Herald | 10506 | Pull: `GASP` | `SIGH` | The summoned herald warrants a cautious visual response. |
| `scholomance-03` Jandice Barov | 10503 | Pull: `NO` | `BOW` | Reject the illusionist's hostility while respecting the fallen Barov. |
| `scholomance-04` Rattlegore | 11622 | Pull: `GASP` | `SIGH` | The bone construct warrants alarm rather than a personal insult. |
| `scholomance-05` Death Knight Darkreaver | 14516 | Pull: `NO` | `VICTORY` | Defy the death knight at the class ritual's conclusion. |
| `scholomance-06` Marduk Blackpool | 10433 | Mål/pull: `SALUTE` | `VICTORY` | A pointed military gesture fits the undead knight. |
| `scholomance-07` Vectus | 10432 | Pull: `NO` | `VICTORY` | Reject the necromantic lecturer's teachings. |
| `scholomance-08` Ras Frostwhisper | 10508 | Pull: `NO` | `SIGH` | Defy the lich without assuming an unobserved quest transformation. |
| `scholomance-09` Kormok | 16118 | Pull: `GASP` | `SIGH` | The summoned ogre is a separate encounter in the lich's room. |
| `scholomance-10` Instructor Malicia | 10505 | Pull: `NO` | `VICTORY` | Reject Malicia's instruction rather than play along. |
| `scholomance-11` Doctor Theolen Krastinov | 11261 | Pull: `NO` | `VICTORY` | Confront the butcher with moral rejection, not medical jokes. |
| `scholomance-12` Lorekeeper Polkelt | 10901 | Pull: `GASP` | `SIGH` | Polkelt's diseased presence warrants cautious relief. |
| `scholomance-13` The Ravenian | 10507 | Pull: `GASP` | `SIGH` | The ravenous creature is a threat rather than comic relief. |
| `scholomance-14` Lord Alexei Barov | 10504 | Mål/pull: `BOW` | `BOW` | Acknowledge the fallen Barov patriarch solemnly. |
| `scholomance-15` Lady Illucia Barov | 10502 | Mål/pull: `BOW` | `BOW` | Acknowledge the fallen Barov matriarch solemnly. |
| `scholomance-16` Darkmaster Gandling | 1853 | Mål/pull: `RASP` | `VICTORY` | Defy the headmaster at the school's final encounter. |

## Stratholme – Live / Scarlet

Instance/map-ID: `329`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `strat-live-01` Skul | 10393 | Pull: `GASP` | `SIGH` | The rare skeletal figure deserves an uneasy response. |
| `strat-live-02` Stratholme Courier | 11082 | Pull: `NOD` | `SIGH` | Acknowledge the courier without inventing a spoken delivery joke. |
| `strat-live-03` Postmaster Malown | 11143 | Mål/pull: `RASP` | `VICTORY` | The undead postmaster permits a pointed defiant gesture. |
| `strat-live-04` Hearthsinger Forresten | 10558 | Mål/pull: `BOW` | `APPLAUD` | Acknowledge the spectral performer with fitting stage gestures. |
| `strat-live-05` The Unforgiven | 10516 | Pull: `GASP` | `BOW` | The unforgiven spirit merits a restrained conclusion. |
| `strat-live-06` Timmy the Cruel | 10808 | Pull: `GASP` | `SIGH` | The charging ghoul warrants unease rather than pop-culture dialogue. |
| `strat-live-07` Crimson Hammersmith | 11120 | Mål/pull: `RASP` | `VICTORY` | Challenge the smith when the plans actually draw him out. |
| `strat-live-08` Ezra Grimm (äldre namn: Fras Siabi) | 11058 | Pull: `NO` | `SIGH` | The tobacco-shop confrontation does not justify mocking the city's dead. |
| `strat-live-09` Cannon Master Willey | 10997 | Mål/pull: `SALUTE` | `VICTORY` | A defiant salute fits the Scarlet cannon commander. |
| `strat-live-10` Archivist Galford | 10811 | Pull: `NO` | `VICTORY` | Reject the hostile archivist without invented book-burning dialogue. |
| `strat-live-11` Grand Crusader Dathrohan / Balnazzar | 10812,10813 | Pull: `NO` | `VICTORY` | Distinguish Dathrohan's guise from the dreadlord's final defeat. |
| `strat-live-12` Jarien / Sothos | 16101,16102 | Mål/pull: `SALUTE` | `BOW` | The two summoned adventurers share a respectful conclusion. |
| `strat-live-13` Malor the Zealous | 11032 | Pull: `NO` | `VICTORY` | Reject the zealot guarding the medallion. |

## Stratholme – Undead / Scourge

Instance/map-ID: `329`.

| Kort / boss | NPC-ID | Öppning | Efter | RP-motivering |
|---|---|---|---|---|
| `strat-undead-01` Magistrate Barthilas | 10435 | Pull: `NO` | `VICTORY` | Reject the magistrate's service to the Scourge. |
| `strat-undead-02` Baroness Anastari | 10436 | Pull: `GASP` | `BOW` | The banshee merits a solemn finish, not a flirt. |
| `strat-undead-03` Nerub'enkan | 10437 | Pull: `GASP` | `SIGH` | The nerubian guardian prompts unease. |
| `strat-undead-04` Maleki the Pallid | 10438 | Pull: `NO` | `VICTORY` | Reject the necromancer at his ziggurat. |
| `strat-undead-05` Stonespine | 10809 | Pull: `GASP` | `SIGH` | A rare gargoyle overhead is a visual surprise. |
| `strat-undead-06` Ramstein the Gorger | 10439 | Pull: `GASP` | `SIGH` | The abomination's fall does not end the following gauntlet. |
| `strat-undead-07` Baron Rivendare | 10440 | Mål/pull: `SALUTE` | `VICTORY` | A defiant salute fits Rivendare's command of the city. |
| `strat-undead-08` Black Guard Swordsmith | 11121 | Mål/pull: `RASP` | `VICTORY` | Challenge the swordsmith only after his special activation. |
