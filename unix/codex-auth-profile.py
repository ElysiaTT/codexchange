#!/usr/bin/env python3
"""Cross-platform Codex auth profile helper."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


PROFILE_RE = re.compile(r"^[A-Za-z0-9._-]+$")


def default_codex_home() -> Path:
    env_home = os.environ.get("CODEX_HOME")
    if env_home:
        return Path(env_home).expanduser()
    return Path.home() / ".codex"


class Paths:
    def __init__(self, codex_home: Path) -> None:
        self.codex_home = codex_home.expanduser()
        self.auth_file = self.codex_home / "auth.json"
        self.profiles_dir = self.codex_home / "auth-profiles"
        self.backups_dir = self.profiles_dir / "_backups"
        self.login_homes_dir = self.profiles_dir / "_login-homes"

    def ensure_dirs(self) -> None:
        self.profiles_dir.mkdir(parents=True, exist_ok=True)
        self.backups_dir.mkdir(parents=True, exist_ok=True)
        self.login_homes_dir.mkdir(parents=True, exist_ok=True)

    def profile_path(self, name: str) -> Path:
        assert_profile_name(name)
        return self.profiles_dir / f"{name}.auth.json"


def assert_profile_name(name: Optional[str]) -> None:
    if not name:
        raise SystemExit("Profile name is required.")
    if name in (".", ".."):
        raise SystemExit("Profile name cannot be '.' or '..'.")
    if not PROFILE_RE.fullmatch(name):
        raise SystemExit(
            "Profile name can only contain letters, numbers, dot, underscore, and hyphen."
        )


def load_json_file(path: Path) -> dict:
    if not path.exists():
        raise SystemExit(f"File not found: {path}")
    try:
        with path.open("r", encoding="utf-8-sig") as f:
            data = json.load(f)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"File is not valid JSON: {path}") from exc
    if not isinstance(data, dict):
        raise SystemExit(f"File is not a JSON object: {path}")
    return data


def file_hash(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest().upper()


def auth_summary(path: Path) -> Dict[str, object]:
    data = load_json_file(path)
    stat = path.stat()
    return {
        "path": str(path),
        "last_write_time": datetime.fromtimestamp(stat.st_mtime).isoformat(timespec="seconds"),
        "auth_mode": data.get("auth_mode", "unknown"),
        "has_api_key": bool(data.get("OPENAI_API_KEY")),
        "has_tokens": "tokens" in data,
        "last_refresh": data.get("last_refresh", ""),
    }


def print_kv(items: Dict[str, object]) -> None:
    width = max(len(k) for k in items)
    for key, value in items.items():
        print(f"{key:<{width}} : {value}")


def print_table(rows: List[Dict[str, object]], columns: List[str]) -> None:
    if not rows:
        return
    widths = {
        col: max(len(col), *(len(str(row.get(col, ""))) for row in rows))
        for col in columns
    }
    print("  ".join(col.ljust(widths[col]) for col in columns))
    print("  ".join("-" * widths[col] for col in columns))
    for row in rows:
        print("  ".join(str(row.get(col, "")).ljust(widths[col]) for col in columns))


def find_codex() -> str:
    env_exe = os.environ.get("CODEX_EXE")
    if env_exe and Path(env_exe).exists():
        return env_exe

    path_exe = shutil.which("codex")
    if path_exe:
        return path_exe

    roots = [
        Path.home() / ".vscode" / "extensions",
        Path.home() / ".vscode-insiders" / "extensions",
        Path.home() / ".vscode-server" / "extensions",
        Path.home() / ".vscode-server-insiders" / "extensions",
    ]
    candidates = []
    for root in roots:
        if not root.exists():
            continue
        for ext in root.glob("openai.chatgpt-*"):
            for exe in ext.glob("bin/*/codex*"):
                if exe.is_file() and os.access(exe, os.X_OK if os.name != "nt" else os.F_OK):
                    candidates.append(exe)
    if candidates:
        return str(max(candidates, key=lambda p: p.stat().st_mtime))

    raise SystemExit(
        "Could not find codex. Install Codex CLI, put codex on PATH, or set CODEX_EXE."
    )


def run_codex(args: List[str], temporary_codex_home: Optional[Path] = None) -> None:
    env = os.environ.copy()
    if temporary_codex_home is not None:
        env["CODEX_HOME"] = str(temporary_codex_home)
    completed = subprocess.run([find_codex(), *args], env=env, check=False)
    if completed.returncode != 0:
        raise SystemExit(f"codex exited with code {completed.returncode}")


def backup_current(paths: Paths, reason: str) -> None:
    paths.ensure_dirs()
    if not paths.auth_file.exists():
        print("No auth.json found to back up.")
        return
    load_json_file(paths.auth_file)
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    safe_reason = re.sub(r"[^A-Za-z0-9._-]", "-", reason)
    target = paths.backups_dir / f"auth.{stamp}.{safe_reason}.json"
    shutil.copy2(paths.auth_file, target)
    print(f"Backed up current auth.json to: {target}")


def command_list(paths: Paths, _args: argparse.Namespace) -> None:
    paths.ensure_dirs()
    profiles = []
    for path in sorted(paths.profiles_dir.glob("*.auth.json")):
        stat = path.stat()
        profiles.append(
            {
                "Profile": path.name[:-10] if path.name.endswith(".auth.json") else path.name,
                "LastWriteTime": datetime.fromtimestamp(stat.st_mtime).isoformat(timespec="seconds"),
                "Length": stat.st_size,
            }
        )
    if not profiles:
        print("No saved Codex auth profiles yet.")
        print("Start with: codex-auth-profile save team-a")
        return
    print_table(profiles, ["Profile", "LastWriteTime", "Length"])


def command_save(paths: Paths, args: argparse.Namespace) -> None:
    paths.ensure_dirs()
    target = paths.profile_path(args.name)
    load_json_file(paths.auth_file)
    if target.exists() and not args.force:
        raise SystemExit(f"Profile already exists: {args.name}. Re-run with --force.")
    shutil.copy2(paths.auth_file, target)
    print(f"Saved current Codex auth as profile '{args.name}': {target}")


def command_use(paths: Paths, args: argparse.Namespace) -> None:
    paths.ensure_dirs()
    source = paths.profile_path(args.name)
    load_json_file(source)
    backup_current(paths, f"before-use-{args.name}")
    shutil.copy2(source, paths.auth_file)
    active_hash = file_hash(paths.auth_file)
    source_hash = file_hash(source)
    if active_hash != source_hash:
        raise SystemExit(
            "Switch verification failed: auth.json does not match the selected profile after copy."
        )
    print(f"Switched Codex auth to profile '{args.name}'.")
    print(f"Verified active auth.json matches '{args.name}' (sha256:{active_hash[:12]}...).")
    print(
        "Restart open Codex sessions, VS Code Codex panels, or the Codex desktop app "
        "for the switch to appear in the UI."
    )


def command_backup(paths: Paths, _args: argparse.Namespace) -> None:
    backup_current(paths, "manual")


def command_status(paths: Paths, _args: argparse.Namespace) -> None:
    if paths.auth_file.exists():
        print_kv(auth_summary(paths.auth_file))
    else:
        print(f"No auth.json found at: {paths.auth_file}")
    print()
    run_codex(["login", "status"])


def command_where(paths: Paths, _args: argparse.Namespace) -> None:
    print_kv(
        {
            "codex_home": paths.codex_home,
            "auth_file": paths.auth_file,
            "profiles_dir": paths.profiles_dir,
            "backups_dir": paths.backups_dir,
            "login_homes_dir": paths.login_homes_dir,
            "codex_exe": find_codex(),
        }
    )


def command_login_as(paths: Paths, args: argparse.Namespace) -> None:
    paths.ensure_dirs()
    assert_profile_name(args.name)
    target = paths.profile_path(args.name)
    if target.exists() and not args.force:
        raise SystemExit(f"Profile already exists: {args.name}. Re-run with --force.")

    login_home = paths.login_homes_dir / args.name
    login_home.mkdir(parents=True, exist_ok=True)
    login_auth = login_home / "auth.json"

    if login_auth.exists() and not args.force:
        raise SystemExit(
            "Temporary login home already has auth.json. Re-run with --force or choose another profile name."
        )
    if login_auth.exists() and args.force:
        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        shutil.copy2(login_auth, paths.backups_dir / f"login-home.{args.name}.{stamp}.auth.json")
        login_auth.unlink()

    login_args = ["login"]
    if args.device_auth:
        login_args.append("--device-auth")

    print(f"Starting isolated Codex login for profile '{args.name}'.")
    print(f"This uses CODEX_HOME={login_home} and does not run 'codex logout' on your main account.")
    run_codex(login_args, login_home)

    load_json_file(login_auth)
    shutil.copy2(login_auth, target)
    print(f"Saved isolated login as profile '{args.name}': {target}")
    print(f"To activate it: codex-auth-profile use {args.name}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="codex-auth-profile",
        description="Switch local Codex auth.json profiles without running codex logout.",
    )
    parser.add_argument(
        "--codex-home",
        default=str(default_codex_home()),
        help="Codex home directory. Defaults to CODEX_HOME or ~/.codex.",
    )

    subparsers = parser.add_subparsers(dest="action", required=True)

    subparsers.add_parser("list", help="List saved profiles").set_defaults(func=command_list)

    save = subparsers.add_parser("save", help="Save active auth.json as a profile")
    save.add_argument("name")
    save.add_argument("-f", "--force", action="store_true")
    save.set_defaults(func=command_save)

    use = subparsers.add_parser("use", help="Activate a saved profile")
    use.add_argument("name")
    use.set_defaults(func=command_use)

    subparsers.add_parser("backup", help="Back up active auth.json").set_defaults(func=command_backup)
    subparsers.add_parser("status", help="Show non-secret auth summary").set_defaults(func=command_status)
    subparsers.add_parser("where", help="Show paths used by the tool").set_defaults(func=command_where)

    login_as = subparsers.add_parser(
        "login-as",
        help="Log in under isolated CODEX_HOME and save as a profile",
    )
    login_as.add_argument("name")
    login_as.add_argument("-f", "--force", action="store_true")
    login_as.add_argument(
        "--device-auth",
        action="store_true",
        help="Pass --device-auth to codex login. Useful on headless servers.",
    )
    login_as.set_defaults(func=command_login_as)

    return parser


def main(argv: Optional[List[str]] = None) -> int:
    if argv is None:
        argv = sys.argv[1:]
    if argv and argv[0] == "help":
        argv = ["--help"]

    parser = build_parser()
    args = parser.parse_args(argv)
    paths = Paths(Path(args.codex_home))
    args.func(paths, args)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(130)
