# HCVoice RP Director 1.7.0

## Highlights

- Contextual character voice and emote reactions for Classic Era, with configurable presets and character profiles.
- 230 Hardcore boss and encounter entries across 26 dungeon and wing sections, using existing Blizzard emotes.
- Automatic boss openings, selected encounter events and confirmed victories, with a master switch and individual dungeon controls.
- Context checks, cooldowns and priorities cancel stale reactions and give urgent danger and mourning precedence.
- Coordinated boss moments between compatible HCVoice group members.
- Includes dungeon social replies, the compact outdoor reply card, and reactions to confirmed pet attack and recall commands.

## Installation and compatibility

Install the complete `HCVoice` folder, including `Bosses`, in the Classic Era `Interface/AddOns` directory. Restart WoW after the first installation; use `/reload` after an update. Open settings with `/hcv`.

Target: **Classic Era 1.15.9**, with English client text recognition. The boss module requires Hardcore to be active. No additional addons or audio downloads are required.

Menus are mainly English; the outdoor reply card currently uses Swedish labels.

## Validation and current limits

All eight runtime Lua files pass Lua 5.1 syntax checks, and all 181 simulated behavior tests pass. These checks cover the shared reaction director and boss logic. Sound, animation, UI appearance, timing and per-encounter signals still need live-client verification. Game restrictions may suppress automatic emotes.

Prepared for distribution with corrected installation documentation and an All Rights Reserved license. Runtime behavior is unchanged from the existing 1.7.0 build.
