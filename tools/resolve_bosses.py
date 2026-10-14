"""Development-only inventory check against the locally installed Classic NPC data.

No Questie dependency is introduced into the addon.
"""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--database', type=Path, default=ROOT.parent / 'Questie/Database/Classic/classicNpcDB.lua')
args = parser.parse_args()
database = args.database
if not database.is_file():
    parser.error('Classic NPC database not found. Supply its local path with --database.')
names = {}
for line in database.read_text(encoding='utf-8-sig').splitlines():
    match = re.match(r'''\[(\d+)\] = \{(['"])((?:\\.|(?!\2).)*?)\2,''', line)
    if match:
        name = match[3].replace("\\'", "'").replace('\\"', '"')
        names.setdefault(name.lower(), []).append(int(match[1]))

special = {
    'Grubbis / Chomper': ['Grubbis', 'Chomper'],
    'The Lost Dwarves: Baelog, Eric "The Swift", Olaf': ['Baelog', 'Eric "The Swift"', 'Olaf'],
    'Sergeant Bly och hans grupp': ['Sergeant Bly', 'Raven', 'Oro Eyegouge', 'Murta Grimgut'],
    'De fem khanerna: Kolk, Gelk, Magra, Maraudos, Veng': ['Kolk', 'Gelk', 'Magra', 'Maraudos', 'Veng'],
    'Theldren och arenagruppen': ['Theldren'],
    "The Seven: Anger'rel, Doom'rel, Dope'rel, Gloom'rel, Hate'rel, Seeth'rel, Vile'rel": ["Anger'rel", "Doom'rel", "Dope'rel", "Gloom'rel", "Hate'rel", "Seeth'rel", "Vile'rel"],
    'Ezra Grimm (äldre namn: Fras Siabi)': ['Fras Siabi'],
}
cards = []
for match in re.finditer(r'^- \[ \] `([^`]+)` (.+?)(?: \[[^\]]+\])?$', (ROOT / 'docs/archive/BOSS_RESEARCH.md').read_text(encoding='utf-8'), re.M):
    key, label = match.groups()
    label = label.removeprefix('Ring of Law: ')
    entries = special.get(label, label.split(' / '))
    found = {name: names.get(name.lower(), []) for name in entries}
    cards.append({'key': key, 'name': label, 'npcs': found})
print(json.dumps(cards, ensure_ascii=False, indent=2))
