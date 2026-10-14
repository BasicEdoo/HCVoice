# Live-client check

Current live result: **pending**. Automated tests use simulated WoW APIs and do not confirm actual audio, UI layout or server encounter signals.

Use ordinary, safe gameplay. Do not deliberately endanger or kill a Hardcore character to test a reaction. Record the exact ZIP and its SHA256 from `BUILD.md`.

## Installation and settings

- [ ] Install the complete ZIP in Classic Era. Confirm `HCVoice/HCVoice.toc` and `HCVoice/Bosses/Content.lua` exist.
- [ ] Restart the game. The addon list shows **HCVoice – RP Reactions** without missing dependencies.
- [ ] `/hcv` opens the settings without Lua errors. The sidebar version matches `BUILD.md`.
- [ ] Open each settings page; check text, buttons and dungeon controls for clipping.
- [ ] Change a harmless setting. After `/reload`, the choice remains. Restore it after the check.
- [ ] `/hcv off` stops automatic reactions; `/hcv on` enables them again.

## Voice and social behavior

- [ ] `/hcv test hello` produces the expected voice or gesture with game sound enabled. Record the actual result.
- [ ] Receive a relevant buff from another player. Check the directed thank-you and that a buff series does not produce repeated replies.
- [ ] Receive buffs from three different helpers close together, including one after the first THANK. Each helper should receive one directed THANK if the quiet context lasts.
- [ ] Buff another player. Your character should not automatically thank them for your own buff.
- [ ] Outside a dungeon, observe a directed greeting and an ambiguous directed interaction. Confirm automatic replies or the reply card follow the selected settings.
- [ ] Check that reply-card labels are English and fit their buttons. Move the card, choose a reply and close it with X or Escape. Confirm the intended recipient and saved position.
- [ ] During ordinary five-player dungeon play, enabled recognized directed replies are automatic and do not open a reply card.
- [ ] Manually answer a directed hug or greeting before HCVoice answers. Confirm no duplicate automatic reply or stale reply card remains.
- [ ] Use your own emote during a quiet moment. HCVoice should not respond to itself through Living World.

## Refined combat and profiles

- [ ] During ordinary safe combat, small hits should not produce HELPME. Record naturally occurring rapid health loss and recovery; do not create danger for the test.
- [ ] During normal play, check that a dead enemy followed by a new attacker is not announced as two simultaneous attackers.
- [ ] If a queued health warning is naturally cancelled by healing, confirm a later real drop can still warn. Record health and timing from the actual encounter.
- [ ] Move the reply card, export settings, change a harmless setting and import the export. The listed behavior settings should return and the card should keep its position.
- [ ] Try importing `HCVOICE_PROFILE_V1;`. It should report an error and preserve current settings.

## Pets and bosses

- [ ] For a pet class, ordinary Attack and Follow commands produce at most the intended voice after confirmation. The player retains pet control.
- [ ] Keep another player selected while calling the pet back. WHISTLE addresses the pet and the selected target stays unchanged. Check the recipient of CHARGE, pet danger and mourning too; a missing pet must stay silent.
- [ ] On Hardcore, the boss master switch and individual dungeon controls work. Record the encounters actually observed.
- [ ] Observe an opening and conclusion during normal dungeon play. Losing combat or seeing a boss disappear must not count as a kill.
- [ ] For multi-stage encounters, verify that the conclusion waits for the relevant final stage.
- [ ] On ordinary non-Hardcore Era, the boss module remains inactive.
- [ ] If the group has several compatible HCVoice users, observe coordination and record duplicate reactions.

## Record

| Item | Result |
|---|---|
| Date and tester | |
| Game build and language | |
| Realm type, class/race and preset | |
| ZIP filename and SHA256 | |
| Encounters observed | |
| Checks passed | |
| Errors or remaining limitations | |
| Release or Beta decision | |

A limited set of live encounters does not prove that every configured boss entry works. Report observations and remaining limits accurately.
