# HCVoice – RP Reactions

<img src="https://raw.githubusercontent.com/BasicEdoo/HCVoice/main/release/assets/hcvoice-icon.png" alt="HCVoice logo" width="144" align="right">

Give your character a voice in World of Warcraft Classic Era.

**Version:** 1.7.3 · **Author:** Edòó · **License:** All Rights Reserved

[![Checks](https://github.com/BasicEdoo/HCVoice/actions/workflows/checks.yml/badge.svg)](https://github.com/BasicEdoo/HCVoice/actions/workflows/checks.yml)

HCVoice uses the game's existing character voices and emotes for contextual roleplay: greetings, thanks, danger calls, pet reactions and shared group moments. The Hardcore module adds reactions for 230 boss and encounter entries across 26 dungeon and wing sections.

[Download on CurseForge](https://www.curseforge.com/wow/addons/hcvoice) · [User guide](docs/USER_GUIDE.md) · [Changelog](CHANGELOG.md)

## Why we created HCVoice

We created HCVoice because we wanted our characters to feel more present in the world of Classic WoW. A stranger gives you a helpful buff. Your pet rushes into a fight. Your party survives a dangerous pull. Those small moments are part of what makes the game memorable, and we wanted our characters to acknowledge them.

The focus is immersion: a timely thank-you, a greeting, a call for help or a shared reaction with your group. By using the voices and emotes already in the game, HCVoice aims to make those expressions feel at home in Classic. Players choose how much their character participates through presets and individual reaction settings.

Knowing when to stay quiet is part of that idea. A call for healing should disappear when health recovers; a celebration should give way to a party member's death. HCVoice checks whether each queued moment still fits the situation, so personality comes from the context and timing of a reaction.

## Quick start

1. Download an install package from [CurseForge](https://www.curseforge.com/wow/addons/hcvoice) and extract its complete `HCVoice` folder into `_classic_era_/Interface/AddOns/`.
2. Restart WoW after the first installation, or use `/reload` after an update.
3. Enter `/hcv` and choose **Quiet**, **Balanced**, **Classic RP** or **Full RP**.
4. Try `/hcv test hello`, then adjust **Reactions** and **Replies**.

Use `/hcv off` to stop automatic reactions and `/hcv on` to enable them again.

To try this source version, clone the repository into a folder named `HCVoice` inside `AddOns`. If using GitHub's **Download ZIP**, rename the extracted `HCVoice-main` folder to `HCVoice`. The final path must be `AddOns/HCVoice/HCVoice.toc`. The source version and the latest CurseForge download may differ.

## What it does

- **Roleplay:** directed greetings and replies, thanks for help and received buffs, group welcomes and farewells, and occasional safe-downtime reactions.
- **Survival and pets:** danger calls, drinking-break signals, pet warnings and mourning, plus reactions to your confirmed pet attack and recall commands.
- **Social choices:** a compact reply card for ambiguous directed interactions outside dungeons; enabled recognized replies run automatically in five-player dungeons.
- **Hardcore bosses:** contextual openings, selected encounter events and confirmed victories, with a master switch and individual dungeon controls.
- **Your settings:** character profiles, import/export, a Voice Lab and recent decision history.

## Compatibility and sound

| Item | Support |
|---|---|
| Client target | Classic Era 1.15.9, Interface 11509 |
| Hardcore | Required for the boss-reaction module |
| Language | English UI; incoming standard-emote text and buff-name recognition target English clients |
| Dependencies | None in the game; no additional audio downloads |
| Other WoW editions | Not verified |

The client controls which emotes produce sound or animation and whether an automatic call is allowed. Some reactions are gestures or text only. Standard Blizzard emote text may appear in chat. Blocked automatic calls stay silent.

HCVoice adds reactions while you control your character and pet. Cooldowns and context checks cancel outdated moments. Quiet reduces participation; group departures still produce a farewell while the addon is enabled.

## How it works

The runtime is Lua 5.1 and loads through the addon's TOC. Gameplay and social events create candidate reactions; a shared director schedules them, merges duplicate moments and rechecks their context before calling the game's emote API.

| Area | Implementation |
|---|---|
| Gameplay events and settings | [HCVoice.lua](HCVoice.lua) |
| Priorities, timing and cancellation | [HCVoice_Director.lua](HCVoice_Director.lua) |
| Directed emotes and reply choices | [HCVoice_Social.lua](HCVoice_Social.lua) |
| Drinking breaks and pet situations | [HCVoice_Situations.lua](HCVoice_Situations.lua) |
| Shared group scenes | [HCVoice_LivingWorld.lua](HCVoice_LivingWorld.lua) |
| Hardcore encounter detection and authored content | [HCVoice_Bosses.lua](HCVoice_Bosses.lua), [Bosses/Content.lua](Bosses/Content.lua) |
| Settings, profiles, Voice Lab and reply card | [HCVoice_GUI.lua](HCVoice_GUI.lua) |

The project brings together event-driven Lua, stateful reaction scheduling, configurable UI, validated profile imports and regression testing. Encounter definitions also generate the [boss reference](docs/BOSS_REACTIONS.md), keeping documented reactions tied to the content used by the addon.

## Development and verification

From a source checkout with Node.js 18+ and Python 3.9+ available:

```sh
npm ci --ignore-scripts
npm test
npm run docs:check
npm run release
```

On Windows PowerShell, use `npm.cmd` if script execution policy blocks `npm`.

The suite parses all eight runtime Lua files and runs **227 simulated behavior tests** for version 1.7.3, including recovery, cancellation, social exchanges, profile validation and boss encounters. The release command checks the ZIP contents and reruns the suite against the extracted package. GitHub Actions runs these checks on pushes and pull requests.

See the [development guide](https://github.com/BasicEdoo/HCVoice/blob/main/docs/DEVELOPMENT.md) for the simulator, repository layout and packaging details. Node.js and Python are development tools; players do not need them.

Automated checks do not establish actual in-game audio, animation, UI layout, timing or individual boss signals. The [live-client checklist](https://github.com/BasicEdoo/HCVoice/blob/main/release/SMOKE_TEST.md) records the remaining manual verification.

## Guides

- [User guide](docs/USER_GUIDE.md): settings, commands, detailed behavior and troubleshooting.
- [Boss reactions](docs/BOSS_REACTIONS.md): every configured encounter and its reaction choices.
- [Changelog](CHANGELOG.md): release history.
- [License](LICENSE.txt): All Rights Reserved.

Bug reports and suggestions can be shared through [GitHub Issues](https://github.com/BasicEdoo/HCVoice/issues). Include the addon version, client version and steps to reproduce the behavior.

Copyright (c) 2026 Edòó. All Rights Reserved; see [LICENSE.txt](LICENSE.txt).
