#!/usr/bin/env python3
"""Build and verify the HCVoice CurseForge ZIP using only Python's standard library."""

import argparse
import hashlib
import io
import json
from pathlib import Path, PurePosixPath
import posixpath
import re
import shutil
import subprocess
import tempfile
import zipfile

from generate_boss_docs import render as render_boss_reference


ROOT = Path(__file__).resolve().parents[1]
ADDON = "HCVoice"
DOCUMENTS = (
    "README.md",
    "CHANGELOG.md",
    "LICENSE.txt",
    "docs/USER_GUIDE.md",
    "docs/BOSS_REACTIONS.md",
)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def collect_inputs():
    toc_name = f"{ADDON}.toc"
    toc_bytes = (ROOT / toc_name).read_bytes()
    metadata = {}
    runtime = []
    for raw in toc_bytes.decode("utf-8-sig").splitlines():
        line = raw.strip()
        if line.startswith("##"):
            key, separator, value = line[2:].partition(":")
            if separator:
                metadata[key.strip()] = value.strip()
        elif line and not line.startswith("#"):
            name = line.replace("\\", "/")
            relative = PurePosixPath(name)
            if (
                relative.is_absolute()
                or ".." in relative.parts
                or ":" in name
                or relative.as_posix() != name
                or relative.suffix != ".lua"
            ):
                raise ValueError(f"Unexpected TOC runtime path: {line}")
            runtime.append(name)

    version = metadata.get("Version", "")
    if not re.fullmatch(r"\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?", version):
        raise ValueError("TOC must contain a valid release version")
    if not re.fullmatch(r"\d+", metadata.get("Interface", "")):
        raise ValueError("TOC must contain one numeric Interface target")
    for key in ("Title", "Author", "Notes", "SavedVariables", "SavedVariablesPerCharacter"):
        if not metadata.get(key):
            raise ValueError(f"Missing TOC metadata: {key}")
    if metadata.get("X-License") != "All Rights Reserved":
        raise ValueError("Recheck the selected license before packaging")
    if metadata["Author"] != "Edòó":
        raise ValueError("Review the public author name before packaging")

    names = [toc_name, *runtime, *DOCUMENTS]
    if not runtime or len({name.casefold() for name in names}) != len(names):
        raise ValueError("TOC runtime list is empty or contains duplicate package paths")

    inputs = {toc_name: toc_bytes}
    for name in names[1:]:
        source = ROOT / name
        if not source.resolve().is_relative_to(ROOT):
            raise ValueError(f"Source escapes the addon folder: {name}")
        if not source.is_file():
            raise ValueError(f"Required package file is missing: {name}")
        inputs[name] = source.read_bytes()
    if any(not data for data in inputs.values()):
        raise ValueError("Package files must not be empty")

    core = inputs[f"{ADDON}.lua"].decode("utf-8-sig")
    lua_version = re.search(r'HCVoice\.version\s*=\s*"([^"]+)"', core)
    if not lua_version or lua_version.group(1) != version:
        raise ValueError("TOC and runtime versions differ")
    display_name = re.search(r'HCVoice\.displayName\s*=\s*"([^"]+)"', core)
    if not display_name or display_name[1] != metadata["Title"]:
        raise ValueError("TOC and runtime display names differ")
    readme = inputs["README.md"].decode("utf-8-sig")
    if readme.splitlines()[0] != f"# {metadata['Title']}" or f"**Version:** {version} " not in readme:
        raise ValueError("README title/version differs from TOC")
    changelog = inputs["CHANGELOG.md"].decode("utf-8-sig")
    latest = re.search(r'^## ([^\n]+)$', changelog, re.M)
    if not latest or latest[1] != version:
        raise ValueError("Changelog version differs from TOC")
    if b"All Rights Reserved." not in inputs["LICENSE.txt"]:
        raise ValueError("License notice differs from TOC")
    development = json.loads((ROOT / "package.json").read_text(encoding="utf-8"))
    if development["version"] != version or development["author"] != metadata["Author"]:
        raise ValueError("Development package metadata differs from TOC")
    if inputs["docs/BOSS_REACTIONS.md"].decode("utf-8") != render_boss_reference():
        raise ValueError("Boss reference is outdated. Run npm run docs:bosses.")
    check_links(inputs)
    check_public_text(inputs)
    return metadata, runtime, inputs


def check_links(inputs):
    for name, data in inputs.items():
        if not name.endswith(".md"):
            continue
        for link in re.findall(r'\]\(([^)]+)\)', data.decode("utf-8-sig")):
            if re.match(r'^[a-z]+:', link, re.I) or link.startswith("#"):
                continue
            target = link.split("#", 1)[0].strip("<>")
            resolved = posixpath.normpath(posixpath.join(posixpath.dirname(name), target))
            if resolved not in inputs:
                raise ValueError(f"Documentation link is missing from ZIP: {name} -> {target}")


def check_public_text(inputs):
    patterns = {
        "local user path": r'[A-Z]:[\\/]+Users[\\/]|/Users/|/home/|file://',
        "email address": r'\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b',
        "BattleTag": r'\b[A-Za-z][A-Za-z0-9]{2,15}#[0-9]{4,8}\b',
        "saved player GUID": r'Player-\d+-[0-9A-F]{6,}',
        "private key": r'-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----',
    }
    for name, data in inputs.items():
        if name.endswith(".png"):
            continue
        content = data.decode("utf-8-sig")
        for label, pattern in patterns.items():
            if re.search(pattern, content, re.I):
                raise ValueError(f"Review public content ({label}): {name}")


def build_archive(inputs):
    buffer = io.BytesIO()
    with zipfile.ZipFile(buffer, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for name, data in sorted(inputs.items()):
            entry = zipfile.ZipInfo(f"{ADDON}/{name}", date_time=(1980, 1, 1, 0, 0, 0))
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            entry.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(entry, data)
    payload = buffer.getvalue()

    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        expected = {f"{ADDON}/{name}" for name in inputs}
        if len(archive.infolist()) != len(expected) or set(archive.namelist()) != expected:
            raise ValueError("ZIP does not match the package allowlist")
        if archive.testzip() is not None:
            raise ValueError("ZIP integrity check failed")
        for name, data in inputs.items():
            if archive.read(f"{ADDON}/{name}") != data:
                raise ValueError(f"ZIP byte verification failed: {name}")
            if (ROOT / name).read_bytes() != data:
                raise ValueError(f"Source changed during packaging; rebuild: {name}")
    return payload


def verify_runtime(payload):
    node = shutil.which("node")
    if not node:
        raise ValueError("Node.js is required for --verify. See docs/DEVELOPMENT.md.")
    with tempfile.TemporaryDirectory(prefix="hcvoice-release-check-") as temp:
        with zipfile.ZipFile(io.BytesIO(payload)) as archive:
            archive.extractall(temp)
        result = subprocess.run(
            [node, str(ROOT / "tests/run.cjs"), str(Path(temp) / ADDON)],
            cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace",
        )
    if result.returncode:
        raise ValueError("Packaged runtime checks failed:\n" + result.stdout + result.stderr)
    count = re.search(r'^Total behavior tests passed: (\d+)$', result.stdout, re.M)
    syntax = re.findall(r'^Lua 5.1 syntax: (.+)$', result.stdout, re.M)
    if not count or not syntax:
        raise ValueError("The test runner did not report a complete result")
    return {"luaFiles": syntax, "simulatedTestsPassed": int(count[1]), "liveGame": "Not tested"}


def publication_material(metadata, inputs, runtime_checks, filename, digest, size):
    files = {
        name: (ROOT / "release" / name).read_bytes()
        for name in ("README.md", "CURSEFORGE_DESCRIPTION.md", "SMOKE_TEST.md", "assets/hcvoice-icon.png")
    }
    changelog = inputs["CHANGELOG.md"].decode("utf-8")
    notes = re.split(r'^## ', changelog, flags=re.M)[1].split("\n", 1)[1].strip()
    version = metadata["Version"]
    files["RELEASE_NOTES.md"] = (
        f"# {metadata['Title']} {version}\n\n{notes}\n\n"
        "Target: Classic Era 1.15.9. The boss module requires Hardcore. "
        "No additional addon or audio package is required.\n\n"
        "## Verification\n\n"
        + (
            f"All {len(runtime_checks['luaFiles'])} runtime Lua files passed Lua 5.1 parsing, "
            f"and {runtime_checks['simulatedTestsPassed']} simulated tests passed against the extracted ZIP.\n"
            if runtime_checks else "Runtime tests were not run for this package.\n"
        )
        + "Live sound, animation, layout, timing and per-boss encounter signals still need in-game verification.\n"
    ).encode("utf-8")
    status = (
        f"{runtime_checks['simulatedTestsPassed']} simulated tests passed against the extracted ZIP; "
        f"{len(runtime_checks['luaFiles'])} Lua files passed syntax checks"
        if runtime_checks else "Not run; use npm run release for a verified build"
    )
    files["BUILD.md"] = (
        f"# {metadata['Title']} {version}\n\n"
        "This report was generated from the package. No upload is performed by the build tool.\n\n"
        "| Item | Result |\n|---|---|\n"
        f"| File | `{filename}` |\n| Bytes | {size} |\n"
        f"| Author | {metadata['Author']} |\n| License | {metadata['X-License']} |\n"
        f"| Interface | {metadata['Interface']} |\n| Packaged files | {len(inputs)} |\n"
        "| ZIP checks | CRC, exact file list, source-byte comparison and documentation links |\n"
        f"| Runtime checks | {status} |\n"
        "| Public text checks | No user paths, email addresses, BattleTags, stored player GUIDs or private-key blocks found |\n"
        "| Live-client checks | Pending |\n\n"
        f"SHA256:\n\n```text\n{digest}\n```\n\n"
        "## Before uploading\n\n"
        "Complete [SMOKE_TEST.md](SMOKE_TEST.md). Review the public CurseForge profile and any new screenshots or links. "
        "The automated text checks do not inspect your account or guarantee that arbitrary personal information is absent.\n\n"
        "Use [README.md](README.md) for the upload fields and [RELEASE_NOTES.md](RELEASE_NOTES.md) for the changelog.\n"
    ).encode("utf-8")
    check_public_text(files)
    return files


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Destination directory for the release material")
    parser.add_argument("--verify", action="store_true", help="Run Lua checks against the extracted ZIP")
    args = parser.parse_args()
    metadata, runtime, inputs = collect_inputs()
    payload = build_archive(inputs)
    filename = f"{ADDON}-{metadata['Version']}.zip"
    digest = sha256(payload)
    runtime_checks = verify_runtime(payload) if args.verify else None
    if runtime_checks and runtime_checks["luaFiles"] != runtime:
        raise ValueError("The runtime checks did not cover the exact TOC load order")
    manifest = {
        "archive": filename,
        "sha256": digest,
        "sizeBytes": len(payload),
        "title": metadata["Title"],
        "version": metadata["Version"],
        "interface": metadata["Interface"],
        "author": metadata["Author"],
        "license": metadata["X-License"],
        "runtimeFiles": runtime,
        "files": [
            {"path": f"{ADDON}/{name}", "sizeBytes": len(data), "sha256": sha256(data)}
            for name, data in sorted(inputs.items())
        ],
        "verification": "ZIP CRC, exact allowlist, every entry byte-matched to source",
        "runtimeChecks": runtime_checks,
    }
    outputs = {
        filename: payload,
        filename + ".sha256": f"{digest}  {filename}\n".encode("ascii"),
        f"{ADDON}-{metadata['Version']}.manifest.json": (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode("utf-8"),
    }
    outputs.update(publication_material(metadata, inputs, runtime_checks, filename, digest, len(payload)))
    for name, data in inputs.items():
        if (ROOT / name).read_bytes() != data:
            raise ValueError(f"Source changed during verification; rebuild: {name}")
    default_name = metadata["Version"] + ("" if args.verify else "-unchecked")
    output = (args.output or ROOT / "release" / "dist" / default_name).resolve()
    for name, data in outputs.items():
        destination = output / name
        if destination.exists() and destination.read_bytes() != data:
            raise ValueError(f"Different artifact already exists; choose a new output folder: {destination}")
    output.mkdir(parents=True, exist_ok=True)
    for name, data in outputs.items():
        destination = output / name
        if not destination.exists():
            destination.parent.mkdir(parents=True, exist_ok=True)
            with destination.open("xb") as handle:
                handle.write(data)
        if destination.read_bytes() != data:
            raise ValueError(f"Written artifact verification failed: {destination}")
    print(f"Verified: {len(runtime)} runtime files, {len(inputs)} packaged files, {len(payload)} bytes")
    print(f"ZIP: {output / filename}")
    print(f"SHA256: {digest}")
    if runtime_checks:
        print(f"Packaged runtime: {runtime_checks['simulatedTestsPassed']} simulated tests passed")


if __name__ == "__main__":
    main()
