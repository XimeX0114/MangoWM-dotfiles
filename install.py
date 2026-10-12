#!/usr/bin/env python3
"""MangoWM dotfiles installer (Arch Linux)."""

import os
import pwd
import shutil
import subprocess
import sys
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent
HOME = Path.home()
CONFIG_SRC = REPO / "config"
CONFIG_DST = HOME / ".config"
BIN_SRC = REPO / "local" / "bin"
BIN_DST = HOME / ".local" / "bin"
STAMP = time.strftime("%Y%m%d-%H%M%S")

PACKAGES = [
    # WM and required tools
    "mangowm",
    "rofi",
    "waybar",
    "wallust",
    "cliphist",
    "wlogout",
    "kitty",
    "fish",
    "networkmanager",  # provides nmtui
    "swww",
    "wl-clipboard",
    # Look and feel
    "ttf-jetbrains-mono-nerd",
    "bibata-cursor-theme",
    "papirus-icon-theme",
    # Apps
    "nautilus",
    "vscodium-bin",
    "zen-browser-bin",
    "gedit",
]


def run(cmd):
    print("$", " ".join(cmd))
    return subprocess.run(cmd).returncode == 0


def in_official_repos(pkg):
    return subprocess.run(
        ["pacman", "-Si", pkg],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    ).returncode == 0


def find_aur_helper():
    for helper in ("paru", "yay"):
        if shutil.which(helper):
            return helper
    return None


def install_packages():
    if not shutil.which("pacman"):
        sys.exit("This script supports Arch-based systems only (pacman not found).")

    official = [p for p in PACKAGES if in_official_repos(p)]
    aur = [p for p in PACKAGES if p not in official]
    failed = []

    if official and not run(["sudo", "pacman", "-S", "--needed", "--noconfirm", *official]):
        failed += official

    if aur:
        helper = find_aur_helper()
        if helper is None:
            print("No AUR helper (paru/yay) found. Install these manually:", *aur)
            failed += aur
        elif not run([helper, "-S", "--needed", "--noconfirm", *aur]):
            failed += aur

    return failed


def backup_if_exists(dst):
    """Move an existing file/folder/symlink aside as <name>.bak-<timestamp>."""
    if dst.exists() or dst.is_symlink():
        backup = dst.with_name(f"{dst.name}.bak-{STAMP}")
        print(f"Backing up {dst} -> {backup}")
        dst.rename(backup)


def copy_configs():
    if not CONFIG_SRC.is_dir():
        print(f"Skipping configs: {CONFIG_SRC} not found")
        return
    CONFIG_DST.mkdir(parents=True, exist_ok=True)
    for src in sorted(CONFIG_SRC.iterdir()):
        dst = CONFIG_DST / src.name
        backup_if_exists(dst)
        if src.is_dir():
            shutil.copytree(src, dst, symlinks=True)
        else:
            shutil.copy2(src, dst)
        print(f"Copied {src.name} -> {dst}")


def copy_scripts():
    if not BIN_SRC.is_dir():
        print(f"Skipping scripts: {BIN_SRC} not found")
        return
    BIN_DST.mkdir(parents=True, exist_ok=True)
    for src in sorted(BIN_SRC.iterdir()):
        if not src.is_file():
            continue
        dst = BIN_DST / src.name
        backup_if_exists(dst)
        shutil.copy2(src, dst)
        dst.chmod(0o755)
        print(f"Copied {src.name} -> {dst}")

    if str(BIN_DST) not in os.environ.get("PATH", "").split(":"):
        print(f"\nNote: {BIN_DST} is not in your PATH. Add it to your shell profile.")


def set_fish_default():
    fish = shutil.which("fish")
    if fish is None:
        print("fish not found, skipping default shell change")
        return

    current = pwd.getpwuid(os.getuid()).pw_shell
    if os.path.basename(current) == "fish":
        print("fish is already the default shell")
        return

    shells = Path("/etc/shells")
    if not shells.exists() or fish not in shells.read_text().split():
        run(["sudo", "sh", "-c", f"echo {fish} >> /etc/shells"])

    if run(["chsh", "-s", fish]):
        print(f"Default shell changed: {current} -> {fish} (takes effect after re-login)")
    else:
        print(f"Could not change the shell automatically. Run: chsh -s {fish}")


def main():
    failed = install_packages()
    copy_configs()
    copy_scripts()
    set_fish_default()
    run(["fc-cache", "-f"])
    if failed:
        print("\nThese packages were not installed:", *failed)
    print("\nDone. Log out and start MangoWM.")


if __name__ == "__main__":
    main()
