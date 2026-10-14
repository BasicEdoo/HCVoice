# Development

HCVoice is a Classic Era Lua addon. Node.js and Python are used only for local checks and packaging. Players do not need them.

## Layout

| Path | Purpose |
|---|---|
| `HCVoice.toc` | Addon metadata and the authoritative runtime load order |
| `HCVoice.lua` | Settings, scenario definitions, event handling and the public addon object |
| `HCVoice_Director.lua` | Shared reaction scheduling and validity checks |
| `HCVoice_Social.lua` | Incoming emote classification and social interactions |
| `HCVoice_Situations.lua` | Drinking breaks and pet situations |
| `HCVoice_LivingWorld.lua` | Group scene coordination |
| `HCVoice_Bosses.lua` | Hardcore encounter engine |
| `Bosses/Content.lua` | Authored boss and encounter definitions |
| `HCVoice_GUI.lua` | Settings, profiles, Voice Lab and reply card |
| `docs/` | User documentation, generated boss reference and maintenance notes |
| `docs/archive/` | Historical planning and verification notes, excluded from releases |
| `tests/` | WoW API simulator and regression suites |
| `tools/` | Documentation generation, NPC reference lookup and packaging |
| `release/` | CurseForge copy, project icon and manual verification checklist |

Runtime filenames, slash commands, frame names and saved-variable names are stable across the 1.7.1 cleanup. The settings schema remains 170. Keep future metadata-only changes separate from saved-settings migrations.

## Setup and checks

Use Node.js 18 or newer and Python 3.9 or newer. From the `HCVoice` source folder:

```powershell
npm.cmd ci --ignore-scripts
npm.cmd test
npm.cmd run docs:check
```

The lockfile pins the development dependency tree. `private: true` prevents accidental npm publication. Dependencies are used for Lua 5.1 parsing and the Fengari simulator; they are excluded from the addon ZIP. [npm package metadata](https://github.com/npm/cli/blob/latest/docs/lib/content/configuring-npm/package-json.md)

The test runner loads the files in TOC order and exercises the real addon code with simulated WoW APIs. To test another extracted addon folder:

```powershell
npm.cmd test -- "path\to\extracted\HCVoice"
```

The behavior fixture is shared by the combat, social and profile refinement
suites before the boss suite runs. These regressions exercise event sequences,
pending-reaction cancellation and preservation of existing settings.

GitHub Actions runs the syntax and behavior suite, generated-documentation check and verified package build on pushes and pull requests. The workflow uses Node.js 24 and Python 3.12. It builds from the source checkout without publishing an addon release.

An existing tool installation can still be selected through `HCV_TEST_DEPS`, which points to a directory containing `luaparse` and `fengari`.

## Boss reference

Edit encounter behavior in `Bosses/Content.lua`, then regenerate the English reference:

```powershell
npm.cmd run docs:bosses
npm.cmd run docs:check
```

The generator verifies unique encounter keys and NPC IDs and derives names, reactions, counts and map sections from the runtime content. It does not execute Lua or prove live encounter behavior. Historical guide links and NPC research remain in `docs/archive/BOSS_RESEARCH.md`.

`python tools/resolve_bosses.py` performs a development-only name lookup against the adjacent Questie Classic NPC database. Use `--database` to select a different local database. Questie is not an addon dependency.

## Build a release

```powershell
npm.cmd run release
```

This checks the generated boss reference, builds an allowlisted ZIP, verifies its entries, runs the Lua suite against the extracted package, and writes the ZIP, hashes, manifest, release notes and publication material into `release/dist/<version>/`.

For a different destination:

```powershell
npm.cmd run release -- --output "path\to\release-folder"
```

`npm.cmd run package` builds a package without running the Lua suite. Its report explicitly records that live and simulated runtime checks were not performed by that command. Existing artifacts with different bytes are never overwritten.

Keep the TOC, runtime version, `package.json`, README version and latest changelog entry aligned. Build output is generated; do not edit its hashes or verification report manually.

Before a public upload, complete [the live-client checklist](../release/SMOKE_TEST.md). Use only **Edòó** as the public author identity. Inspect any new screenshots, logs, contact links and account profile details before making them public.
