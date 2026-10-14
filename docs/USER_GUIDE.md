# User guide

HCVoice adds contextual Blizzard voice-emotes to World of Warcraft Classic Era.
It uses the character's built-in voices. No external audio or runtime libraries
are included.

## Quick Start

Install the complete HCVoice folder in `_classic_era_/Interface/AddOns`, then
restart WoW for a first installation. Type `/hcv` to open settings and choose
Quiet, Balanced, Classic RP or Full RP. Use `/hcv test hello` to try a voice.
Use `/hcv off` to disable automatic reactions and `/hcv on` to enable them again.

Target client: Classic Era 1.15.9, including official Hardcore realms.
Boss reactions require Hardcore to be active. English is the supported client
language for incoming standard-emote text and received-buff name recognition.
The settings and reply card use English labels.
Other WoW editions and non-English client behavior have not been verified.

## Boss Reactions - Classic Era Hardcore

230 authored boss/encounter cards across 26 dungeon/wing sections use existing
Blizzard voices, sounds and visible animations. They react automatically, with
no boss popups or custom dialogue. Standard Blizzard emote text may accompany
the gesture. Real audio and animation remain controlled by the game client.

Use `/reload`, then `/hcv` > Reactions > Boss reactions - Classic Era Hardcore.
There is one master switch plus a switch for each dungeon/wing. Enabled by
default; the Quiet preset leaves boss reactions off. Existing choices survive.
Only the Classic Era client with Hardcore active runs this content. Dungeon
rares, quest encounters, UBRS groups and Maraudon's outer khans are included;
actual raid instances and other game versions do not activate the package.

Openings require the correct hostile target and a real encounter or sustained
attention. Selected transitions have their own reactions. Victory requires
observed deaths and a quiet group; multi-NPC encounters use explicit completion
rules. Fleeing, despawning, losing the target or leaving combat never proves a
kill. Danger, mourning, casting and control loss cancel cosmetic reactions.
Boss reactions have at least 12 seconds between them. Some moments stay silent
when another voice has priority. Compatible HCVoice clients coordinate using hidden
addon messages; incoming packets cannot create encounters or trigger voices.

See the [boss reference](BOSS_REACTIONS.md) for all choices, NPC IDs, triggers and
special rules. Implementation is covered by simulated tests; actual per-boss
playback and timing still require testing in the running game.

## Dungeons

Inside 5-player dungeons, enabled directed replies are fully automatic, including
during combat. Recognized flirting, hugs, insults, requests and tactical calls
receive contextual answers with no reply popup. Readiness and the recipient are
checked again before playback. Custom or unknown emotes stay silent.

Dungeon replies use the usual cooldowns and priority rules, without the reply
chance roll or the outside-dungeon combat restriction. Explicit off settings,
category exclusions, ignored players and client restrictions still apply.
Entering a dungeon closes an existing popup; leaving cancels pending dungeon
answers and restores the ordinary reply rules. No old popup is replayed.
Raids and battlegrounds keep their existing behavior.

## Pet Commands

Sending a living pet to attack an enemy produces CHARGE after the attack is
confirmed. Calling an attacking pet or a pet on Stay back with Follow produces
WHISTLE. Use your usual pet buttons, keybinds or /petattack and /petfollow macros.
HCVoice adds the voice reaction; you still control the pet yourself.
Both reactions are directed at your pet, including when you have a player or
enemy selected. Your selected target stays unchanged.

CHARGE plays at most once per fight. Both reactions have an eight-second
cooldown, and repeated commands are merged. Automatic pet defense, ordinary
returns after a kill and Follow while already following do not produce voices.
Dead or missing pets, failed commands and outdated targets stay silent.
Changing the command cancels an old queued voice. Urgent danger has priority.

These reactions also work during combat and in dungeons, without popups.
Find "Send pet to attack" and "Call pet back" under Reactions > Combat.
Both are automatic by default; Quiet leaves them off.

## Natural Reactions

Local scenes, automatic replies and Living World use the same reaction director.
Every queued reaction is checked again before the emote call. Recovered health
and mana, changed targets, disabled settings and expired moments cancel stale
reactions. Urgent voices and pet commands use 1.25-second spacing; social voices use the selected
social spacing. Simultaneous danger signals are merged into the strongest call.
These settings govern attempts; the game still controls actual voice playback.

Small routine hits do not call for help. Rapid hostile health loss can produce
HELPME: direct damage must outpace observed recovery by at least 20% of maximum
health over four seconds, with health at 75% or less. The configured lower
health thresholds select HEALME or FLEE instead.
Recovery cancels queued help calls. Confirmed dead attackers no longer count
toward a second-attacker warning, and a cancelled health warning can respond
to a later real drop without having to recover to its full rearm threshold.

Giving another player a buff is silent. A pending target greeting is cancelled
when that target is buffed. Receiving a recognized important class buff can
produce one targeted THANK. Each distinct provider is eligible independently;
the same-provider cooldown covers a series of buffs from that player.
The received-buff delay is 0.5 seconds before entering the social reaction queue.
Self-buffs and passive aura effects remain silent.

Deliberately holding a suitable friendly or neutral non-attackable player target
outside your group can start HELLO. Ordinary party/raid targeting, NPC windows
and proximity never start greetings. A brief target switch does not end an
established encounter immediately.

Every observed party/raid departure triggers exactly BYE to the departing player
while HCV is on, including Quiet mode. There is no chance roll, cooldown,
minimum membership time or combat suppression. A pending welcome is cancelled
when that member leaves. Initial roster reads do not trigger departures.

Clear directed greetings and thanks can receive a natural delayed reply.
Conversation cooldowns distinguish greetings, gratitude and other exchanges.
Your own visible/manual emotes also give the automatic director space and
resolve a pending reply to the same player. They never create a Living World
reply to yourself.

Outside dungeons, flirting, insults, requests and other directed emotes may
offer a popup. It never selects an answer for you. A new sender cannot replace
an active choice. Contextual FLIRT, KISS and HUG choices are available without
a separate activation setting. You choose the answer; the recipient is checked
again at click time. The popup is movable and remembers its position.
The compact reply card defaults to the right edge, measures 320 by 140 UI
units (110 high with only one row of answers), and keeps every answer one
click away. Hover over its text for the full message. Close with X or Escape;
ignoring a player is a separate, subdued action below the answers.

Deaths take precedence over celebrations. Mourning waits until combat ends,
subject to expiry, and humor stays quiet for a short period after a death or
serious danger. Near-death relief no longer randomly becomes a joke.

Long stationary waits can rarely produce an untargeted BORED, YAWN or WHISTLE,
alone or in a party. The default wait is five minutes, with a 15% base chance
and a ten-minute reaction cooldown; local frequency and existing settings apply.
Movement, spellcasting, channeling, party combat, a dead party member and raids
prevent idle reactions. Conditions are checked again before playback.
Idle emotes do not start shared response scenes or an immediate party joke.

Tauren can occasionally MOO instead of JOKE during safe party downtime or travel.
MOO is filtered out of selection and Voice Lab for other races, and the emote
call itself also checks race. SIGH keeps its relief and recovery scenarios.
HUG stays available as an explicit text RP exception and a contextual reply.

Directed MOO now receives a playful MOO from Tauren or LAUGH from other races,
with conversation cooldowns preventing reply chains. Directed WHISTLE, SIGH,
YAWN and BORED offer fitting choices. Ambient versions stay silent; custom
prose never becomes an automatic reply. A whistle is not assumed to be a flirt.

Starting a recognized Drink buff at 60% mana or less in a safe party can say
WAIT once. Queued OOM and extra waiting/idle reactions yield to that break.
After an announced drink ends with at least 90% mana and three seconds elapsed,
NOD can signal completion. Walking away with enough mana counts as finishing.
Leaving early with low mana, combat, party changes and blocked WAIT calls never
produce a misleading ready signal. Reloading during a drink stays silent.

Your pet falling to 25% health in combat can trigger HELPME; your own emergency
has higher priority. The pet warning rearms at 60% health and has a cooldown.
A confirmed pet death can produce MOURN or CRY after combat, within 45 seconds.
Dismissal, replacement and missing health data are not treated as death.
Healing, revival and replacement cancel outdated queued pet reactions.
These reactions are directed at your pet using existing Blizzard emotes.
If the pet is no longer available as a recipient, the reaction stays silent.

These scenarios have individual settings under Reactions. Quiet leaves
them off; other presets enable them. Existing custom scenario choices survive.

Healing thanks use each helper's effective healing total. A completed trade is
thanked only after completion confirmation, using the trade partner rather than
the current target. Party and raid members' level/death transitions are tracked.

## Living World

Compatible HCV clients can coordinate group moments using compact addon messages.
A local observation and a synced copy of the same moment are merged. Major
moments allow each eligible player to react once. Party-joke initiators choose
at most one known compatible responder. Uncoordinated visible group banter
stays silent; directed emotes still use the normal reply rules.

Living World uses scene protocol 2 and periodic group capability announcements.
It can read legacy protocol-1 scenes. Older clients ignore new protocol-2
scenes; upgrade participating clients for coordinated responses. Players without
HCV can still exchange ordinary recognized directed emotes with you.
Simulation commands do not transmit their simulated responses to the group.
HCV never sends ordinary chat text.

## Settings And Profiles

`/hcv` opens the settings window.

| Page | Controls |
|---|---|
| Overview | Master switch, local frequency, social spacing and presets. |
| Reactions | Survival thresholds and local scenario modes. |
| Replies | Encounters, shared-scene frequency, replies and popup choices. |
| Profiles | Save, load, export or import character settings. |
| Voice Lab | Deliberate manual voice tests. |
| Advanced | Detection timing and cooldown maintenance. |
| Recent decisions | The latest 50 local decisions and their reasons. |

Quiet disables automatic direct replies and Living World, retaining its listed
important local events. Balanced, Classic RP and Full RP increase participation.
Presets configure all three systems while preserving category exclusions.
Party departures always trigger BYE while HCV is on.

Local RP frequency, outside-dungeon reply chance and shared-scene frequency are
separate. Popup duration and preview buttons apply outside dungeons only.
The master checkbox and `/hcv off` both cancel queued and delayed automatic work.
Manual Voice Lab tests remain available while automatic reactions are off.

Existing character settings and named profiles are migrated. The removed
outgoing-buff, intimate-activation and optional party-farewell settings are
discarded. Profile strings are validated as settings data and never executed.
Empty or malformed imports leave current settings and pending reactions intact.
A valid import applies its listed settings and retains omitted settings, window
placement and local diagnostic preferences. Ignore choices last until reload/login and survive
switching the addon off/on or changing a profile.

## Commands

| Command | Action |
|---|---|
| `/hcv` | Open or close settings |
| `/hcv close` | Close settings and transient popups |
| `/hcv on` | Enable automatic reactions |
| `/hcv off` | Disable and cancel automatic reactions |
| `/hcv status` | Display current settings |
| `/hcv history` | Print the recent decision history locally |
| `/hcv test hello` | Manually test an emote |
| `/hcv targettest wave` | Manually test against your current target |
| `/hcv lwtest` | List simulated Living World scenes |
| `/hcv reset` | Reset this character's settings |
| `/hcvoice` | Longer alias |

## Installation And Verification

Keep the complete HCVoice folder inside Interface/AddOns, including its Bosses
subfolder. All eight Lua files listed in HCVoice.toc are required. Restart WoW
after a first installation; run `/reload` after updating while the game is open.

TOC target: Classic Era Interface 11509 (game version 1.15.9).
Automated checks cover Lua 5.1 syntax and simulated behavior tests. They do
not prove audible playback, final UI layout or timing on a live server.
After installing, check `/hcv`, `/hcv test hello`, saved settings after `/reload`,
and the reactions you use in normal play. Check the game's sound settings if
voices are inaudible. Use `/hcv history` for local diagnostic information.

English standard emote text is recognized. Custom emote prose is never answered
automatically. Other locales fall back to conservative unknown-emote handling;
received-buff name recognition currently uses English names.

If the client blocks an automatic emote, HCV stays silent. A completed API call
in the decision history means an attempt, not confirmation that audio played.

Author: Edòó
License: All Rights Reserved. See [LICENSE.txt](../LICENSE.txt).
