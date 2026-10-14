"""Generate or check the English boss reference from the runtime catalogue."""

import argparse
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
DESTINATION = ROOT / "docs/BOSS_REACTIONS.md"


def string_field(line, key):
    match = re.search(r'\b' + key + r' = ("(?:[^"\\]|\\.)*")', line)
    if not match:
        raise ValueError(f"Missing string field: {key}")
    return json.loads(match[1])


def read_content():
    source = (ROOT / "Bosses/Content.lua").read_text(encoding="utf-8-sig")
    dungeons = re.findall(r'B:RegisterDungeon\("([^"]+)", "([^"]+)", (\d+)\)', source)
    cards = []
    keys = set()
    npc_ids = set()
    dungeon_keys = {key for key, _, _ in dungeons}
    for line in source.splitlines():
        if not line.startswith("B:Register({"):
            continue
        card = {
            key: string_field(line, key)
            for key in ("key", "dungeon", "name", "open", "victory", "rationale")
        }
        match = re.search(r'npcs = \{([\d, ]+)\}', line)
        if not match:
            raise ValueError(f"Missing NPC list: {card['key']}")
        card["npcs"] = [int(value) for value in match[1].split(",")]
        card["notice"] = "notice = true" in line
        if card["key"] in keys or card["dungeon"] not in dungeon_keys:
            raise ValueError(f"Duplicate encounter or unknown dungeon: {card['key']}")
        if len(set(card["npcs"])) != len(card["npcs"]) or npc_ids.intersection(card["npcs"]):
            raise ValueError(f"Duplicate NPC registration: {card['key']}")
        keys.add(card["key"])
        npc_ids.update(card["npcs"])
        cards.append(card)
    if not cards or len(cards) != len(re.findall(r'^B:Register\(', source, re.M)):
        raise ValueError("Encounter registration format changed; update the documentation parser")
    if len(dungeon_keys) != len(dungeons):
        raise ValueError("Duplicate dungeon key")
    if dungeon_keys != {card["dungeon"] for card in cards}:
        raise ValueError("An empty dungeon section would be omitted")
    return dungeons, cards


def render():
    dungeons, cards = read_content()
    sources = json.loads((ROOT / "docs/BOSS_SOURCES.json").read_text(encoding="utf-8"))
    if set(sources) != {key for key, _, _ in dungeons}:
        raise ValueError("Dungeon source records and runtime content differ")
    toc = (ROOT / "HCVoice.toc").read_text(encoding="utf-8-sig")
    version = re.search(r'^## Version: (.+)$', toc, re.M)[1]
    lines = [
        "# Boss reactions", "",
        f"HCVoice {version} contains **{len(cards)} encounter entries across {len(dungeons)} dungeon and wing sections**. Each entry selects existing Blizzard emotes. These are not new voice recordings.", "",
        "The module runs only in Classic Era with Hardcore active. It observes your group's encounters and uses the normal reaction priorities. Actual voice, animation and encounter signals still require live-game verification.", "",
        "## Reading the tables", "",
        "- **Target/pull:** the opener may be attempted after 1.5 seconds of sustained hostile targeting outside combat, or when your group first engages the encounter.",
        "- **Pull:** the opener requires an observed encounter. Both opening modes require your character to retain the correct hostile target.",
        "- **Conclusion:** observed deaths must satisfy the encounter's completion rules, followed by at least four seconds without group combat. Herod and Ramstein wait at least twelve seconds.",
        "- Danger, mourning, casting, channeling, control loss, client restrictions and voice spacing can suppress a cosmetic reaction. An opener is not guaranteed at every pull.",
        "- Boss reactions are at least twelve seconds apart. Openings and phase moments expire after three seconds. There are no boss reply cards or custom dialogue lines.",
        "- The rationale column describes the addon's roleplay choices, not quoted dialogue or canonical lore. Standard Blizzard emote text may still appear.", "",
        "## Special encounter rules", "",
        "| Encounter | Observed signal and completion rule |", "|---|---|",
        "| Sneed | GASP when the pilot participates after the shredder. Both must be defeated. |",
        "| Mr. Smite | GASP after the player's Smite Stomp aura (6432) is actually removed. No estimated stun timer. |",
        "| Mograine / Whitemane | GASP on Scarlet Resurrection (9232). Mograine's death evidence is cleared; both must be defeated. |",
        "| Halycon / Gizrul | GASP when Gizrul participates. Both must be defeated. |",
        "| Gyth / Rend | ROAR when Rend participates. Both must be defeated. |",
        "| Dreadsteed / Hel'nurath | GASP when Hel'nurath participates. Both must be defeated. |",
        "| Dathrohan / Balnazzar | GASP when Balnazzar is identified in combat. Dathrohan's form alone does not prove completion. |",
        "| Thaurissan / Moira | Only the emperor's death is required. Moira does not need to die. |",
        "| Gordok / Cho'Rush | Only the king's death is required. This does not establish a complete tribute run. |",
        "| Maraudon khans | Each khan is a separate encounter, including the three in the outer caves. |",
        "| Other grouped entries | All listed NPCs must have been observed participating and then dying. |", "",
        "Phase reactions require an already observed encounter. At most two signature reactions can occur per encounter, with at most one per defined signal. Missing signals, resets and despawns do not create a victory.", "",
    ]
    for key, name, map_id in dungeons:
        reference = sources[key]
        lines.extend([
            f"## {name}", "", f"Instance/map ID: `{map_id}`.", "",
            f"Authoring reference: [{name} guide]({reference['url']}).", "",
            "| Entry / encounter | NPC IDs | Opening | Conclusion | Roleplay rationale |",
            "|---|---|---|---|---|",
        ])
        for card in cards:
            if card["dungeon"] != key:
                continue
            mode = "Target/pull" if card["notice"] else "Pull"
            ids = ", ".join(str(value) for value in card["npcs"])
            label = card["name"].replace("|", "\\|")
            rationale = card["rationale"].replace("|", "\\|")
            lines.append(
                f'| `{card["key"]}` {label} | {ids} | {mode}: `{card["open"]}` '
                f'| `{card["victory"]}` | {rationale} |'
            )
        lines.append("")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if the generated reference is outdated")
    args = parser.parse_args()
    expected = render()
    if args.check:
        if not DESTINATION.exists() or DESTINATION.read_text(encoding="utf-8") != expected:
            raise SystemExit("Boss reference is outdated. Run npm run docs:bosses.")
        print("Boss reference matches the runtime catalogue.")
    else:
        DESTINATION.write_bytes(expected.encode("utf-8"))
        dungeons, cards = read_content()
        print(f"Documented {len(cards)} encounters in {len(dungeons)} sections.")


if __name__ == "__main__":
    main()
