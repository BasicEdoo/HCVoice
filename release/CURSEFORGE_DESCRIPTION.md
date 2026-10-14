# Give your character a voice

HCVoice – RP Reactions adds contextual character reactions to **World of Warcraft Classic Era**. Your character can thank someone for a useful buff, greet another player, call for help, react to a pet command and share a quiet moment with the group using Blizzard's existing emotes and character voices.

## Reactions that fit the moment

- **Everyday roleplay:** directed greetings and replies, thanks for received buffs and help, group welcomes and farewells, and occasional reactions during safe downtime.
- **Survival and pets:** health and mana warnings, drinking-break signals, pet danger and mourning, plus a charge or recall whistle after your own pet command is confirmed.
- **Social choices:** outside dungeons, ambiguous directed interactions can offer a small, movable reply card. In five-player dungeons, enabled replies to recognized emotes run automatically, including during combat.
- **Living World:** compatible HCVoice users can coordinate group moments through addon messages. Other players do not need HCVoice for ordinary directed emote interactions.
- **Personal settings:** Quiet, Balanced, Classic RP and Full RP presets, individual reaction controls, character profiles, import/export, a Voice Lab and recent decision history.

Cooldowns, priorities and context checks help keep reactions relevant. Old queued reactions are cancelled when the moment changes. Ordinary Blizzard emote text may appear in chat.

## Hardcore dungeon boss reactions

The Hardcore module includes **230 configured boss and encounter entries across 26 dungeon and wing sections**. These select existing emotes for openings, selected encounter events and confirmed victories. They do not add 230 new voice recordings.

Boss reactions require **Classic Era with Hardcore active**. Each dungeon or wing has its own switch. Boss moments run automatically without reply cards; urgent reactions and mourning take priority. The catalogue includes dungeon rares and selected quest encounters. Raid instances are outside its scope.

## Getting started

1. Install HCVoice for your **Classic Era** installation and restart WoW.
2. Enter `/hcv` to open settings and choose a preset.
3. Try `/hcv test hello`, or open **Voice Lab** to test an emote manually.
4. Adjust **Reactions** and **Replies** to suit your character.

Use `/hcv off` to stop automatic reactions and `/hcv on` to enable them again. Quiet reduces participation; group departures still trigger a farewell while the addon is enabled.

For manual installation, extract the ZIP so the path is `_classic_era_/Interface/AddOns/HCVoice/HCVoice.toc`, with the `Bosses` subfolder alongside the Lua files. When updating an existing installation, use `/reload`.

## Compatibility and sound

- **Target:** Classic Era **1.15.9**, including official Hardcore realms. Boss reactions activate only in Hardcore.
- **Language:** English is the supported client language for incoming standard-emote text and received-buff names. Other locales have limited text recognition and have not been verified.
- **Interface language:** English, including the reply card.
- **Dependencies:** none. HCVoice does not bundle additional audio or runtime libraries.
- **Playback:** the game client determines whether an emote has a voice or animation and whether an automatic call is allowed. Some emotes are gestures or text only. A blocked automatic call stays silent.
- **Validation:** Lua syntax and simulated behavior checks pass. Live sound, UI appearance, timing and individual boss encounter signals still need in-game verification.

HCVoice adds character reactions; you continue to control movement, abilities, targets and pets yourself.

## Feedback

When reporting a problem, include the HCVoice version, game version, client language, preset, what happened and what you expected. Include the exact Lua error if one appears. `/hcv history` can help identify the attempted reaction; remove character names before sharing it.

**Created by Edòó. All Rights Reserved.**
