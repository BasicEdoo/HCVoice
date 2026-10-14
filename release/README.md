# CurseForge publication guide

This directory contains the maintained project description, original project icon and live-client checklist. Build the upload material with `npm.cmd run release` from the HCVoice source folder. The result appears in `release/dist/<version>/`.

The generated `BUILD.md` identifies the exact ZIP, version, hash and checks. `RELEASE_NOTES.md` is generated from the current changelog entry. These files describe the build, not the state of the CurseForge account or any owner-led upload.

## Project fields

| Field | Value |
|---|---|
| Game | World of Warcraft |
| Name | HCVoice – RP Reactions |
| Suggested slug | hcvoice, subject to availability |
| Summary | Contextual character voices and roleplay reactions for Classic Era, with Hardcore dungeon boss moments. |
| Class | Addons |
| Main category | Roleplay |
| Additional categories | Audio & Video; Chat & Communication; Combat |
| Public author | Edòó |
| License | All Rights Reserved |
| Logo | `assets/hcvoice-icon.png` |
| Description | [CURSEFORGE_DESCRIPTION.md](CURSEFORGE_DESCRIPTION.md), using Markdown mode |
| Comments | Enabled for feedback |
| Experimental | Disabled for normal distribution |
| Flavor / version type | Classic / WoW Classic (Era) |
| Supported game version | 1.15.9 |
| File / display name | Use the version and filename in the generated `BUILD.md` |
| Changelog | Use the generated `RELEASE_NOTES.md` |
| Required dependencies | None |

Boss reactions require Hardcore to be active. Other game editions and client versions have not been verified. Confirm the project name and slug in the form; no project ID or public URL is assumed in the source files.

## Distribution choice

Choose the distribution setting explicitly. For an initial release focused on CurseForge, the suggested choice is to disable third-party distribution. Enabling it lets third-party services access the project through CurseForge's API; those downloads do not count toward CurseForge download totals or rewards. This choice can be changed later and is separate from the license. [Project Distribution Toggle](https://support.curseforge.com/support/solutions/articles/9000207877)

## Review before submitting

1. Complete [SMOKE_TEST.md](SMOKE_TEST.md) against the exact ZIP to be uploaded. Record actual sound, UI and gameplay observations.
2. Choose **Release** after the basic live-client checks pass. Use **Beta** for an explicitly early testing build and retain the known limitations in the release notes. CurseForge requires at least one Release file for normal app synchronization. [File types and submission](https://support.curseforge.com/support/solutions/articles/9000197241)
3. Review the public account name, profile text and links. Use **Edòó** for the author identity. No account profile is inspected by the local build tools.
4. Review the icon and description, then submit through [CurseForge Authors](https://authors.curseforge.com/#/projects/create/choose-game) when ready.

The icon is a 1254 x 1254 PNG. Its image-generation provenance is retained. Use real game screenshots when showing the UI; inspect names, chat, BattleTags and other personal information before uploading them. A CurseForge profile or project link should be verified before being used as a public contact link.

## Package contents

The install ZIP contains one `HCVoice/` folder with the TOC, its eight runtime Lua files, README, changelog, license, user guide and English boss reference. The folder name and saved-variable names stay stable across updates.

Historical notes, development dependencies, tests, tools and publication assets are excluded from the install ZIP. The icon and page text are supplied separately for the project page. The packager checks documentation links, source bytes, ZIP integrity and common personal-information patterns. These checks do not replace reviewing newly added content.

## Format references

- The project icon should be an original square PNG of at least 400 x 400 pixels. [Submission guide](https://support.curseforge.com/support/solutions/articles/9000199552)
- The ZIP needs a matching `HCVoice/HCVoice.toc` path and no loose files at its root. [WoW file processor requirements](https://support.curseforge.com/support/solutions/articles/9000210425-elerium-file-processor-errors-per-game)
- Use a single root folder without a version number. [Known issues](https://support.curseforge.com/support/solutions/articles/9000196615)
