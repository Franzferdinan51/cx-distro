# DuckBotOS Build Pipeline

> Forked from [cxlinux-ai/cx-distro](https://github.com/cxlinux-ai/cx-distro) → [Franzferdinan51/cx-distro](https://github.com/Franzferdinan51/cx-distro)
>
> Build system for **DuckBotOS** — a custom Ubuntu 24.04 LTS-based agent-first operating system.

## What This Is

This repository is the **ISO build pipeline** for DuckBotOS. It is a subdirectory of the main [DuckBotOS project](https://github.com/Franzferdinan51/DuckBotOS) and is not meant to be used standalone.

```
DuckBotOS (main repo)
└── cx-distro/          ← this repository
    ├── src/build.sh    ← build entry point
    ├── src/args.sh     ← Ubuntu 24.04 Noble config
    ├── src/mods/       ← build-time patches
    ├── packages/       ← DuckBotOS Debian packages
    └── Makefile        ← build commands
```

## Quick Start (in a Linux VM)

```bash
# Clone the main DuckBotOS repo (includes this subdirectory)
git clone --recurse-submodules https://github.com/Franzferdinan51/DuckBotOS
cd DuckBotOS/cx-distro

# Install build dependencies
sudo apt update && sudo apt install -y live-build debootstrap squashfs-tools xorriso ...

# Build the ISO
make deps
make iso
# Output: output/duckbotos-*.iso
```

## DuckBotOS Packages

| Package | Description |
|---------|-------------|
| `duckbotos-base` | Core OS: Ubuntu Server + Python + Node + Weston |
| `duckbotos-hermes` | Hermes v0.17 "Reach" agent + web dashboard at :9119 |
| `duckbotos-openclaw` | OpenClaw gateway + openclaw-os at :18789 |
| `duckbotos-lm-studio` | LM Studio API server at :1234 (GPU-accelerated local models) |
| `duckbotos-browseros` | BrowserOS as default browser |
| `duckbotos-computer-use` | Newest Desktop Control (Lobster Edition) MCP server (AT-SPI2 + Wayland desktop control) |
| `duckbotos-kiosk` | Weston + Chromium kiosk shell (the OS surface) |
| `duckbotos-session-picker` | Web UI for choosing Hermes / OpenClaw / Hybrid mode |
| `duckbotos-hybrid` | Both-mode: Hermes + OpenClaw with session picker |
| `duckbotos-meta` | Meta-packages: hermes / openclaw / hybrid defaults |
| `duckbotos-branding` | Plymouth theme, GDM, MOTD, wallpapers |

## Build Modes

Set `DUCKBOTOS_MODE` before building:

```bash
DUCKBOTOS_MODE=hermes make iso   # Hermes-only ISO
DUCKBOTOS_MODE=openclaw make iso # OpenClaw-only ISO
DUCKBOTOS_MODE=both make iso     # Both agents + session picker
```

## Architecture

```
ISO build (cx-distro/)     →  DuckBotOS.iso
├── debootstrap Ubuntu 24.04
├── apply src/mods/ patches
│   ├── 50-duckbotos-meta-mod       (selects packages by mode)
│   └── 51-duckbotos-install-mod    (clones packages, builds, installs)
├── install duckbotos-* packages
└── package as .iso
    └── User boots .iso
        ├── Kiosk loads agent URL
        ├── Agent starts at boot
        └── User talks to the OS via natural language
```

## License

- **Build pipeline code**: Apache 2.0 (Franzferdinan51)
- **cxlinux-ai/cx-distro inherited code**: BSL 1.1 (free for personal use, converts to Apache 2032)
- **Hermes**: MIT (NousResearch)
- **OpenClaw**: MIT (OpenClaw team)
- **Newest Desktop Control (Lobster Edition)**: TBD (agent-sh)
- **BrowserOS**: TBD (browseros-ai)

## Upstream Tracking

```bash
git remote add upstream https://github.com/cxlinux-ai/cx-distro.git
git fetch upstream
# Merge upstream changes:
git merge upstream/main --no-edit
```

## CI/CD

GitHub Actions auto-builds the ISO on every push to `duckbotos` branch.
See `.github/workflows/build-iso.yml` in the main DuckBotOS repo.