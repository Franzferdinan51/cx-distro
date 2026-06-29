# cx-distro — DuckBotOS ISO Builder

> For agents working in this directory: DuckBotOS is the parent context.
> See `~/Desktop/DuckBotOS/CLAUDE.md` for the full DuckBotOS overview.

## Purpose
ISO build pipeline for **DuckBotOS** — creates bootable Ubuntu 24.04-based images with Hermes and/or OpenClaw agents pre-installed.

## Relationship to DuckBotOS

```
DuckBotOS/ (main repo — github.com/Franzferdinan51/DuckBotOS)
└── cx-distro/  ← you are here
    ├── packages/    ← duckbotos-* Debian packages (actual buildable source)
    ├── src/         ← build scripts, live-build config, mods
    ├── scripts/     ← build helpers
    └── iso/         ← live-build config (auto-generated at build time)
```

This is a **sibling subdirectory** of DuckBotOS/main. The build-iso.yml workflow in DuckBotOS clones this repo fresh on every CI run.

## Key Directories

```
cx-distro/
├── packages/         ← duckbotos-* Debian source packages (15 total)
│   ├── duckbotos-base/
│   ├── duckbotos-hermes/     ← Hermes agent gateway + dashboard :9119
│   ├── duckbotos-openclaw/   ← OpenClaw gateway + openclaw-os :18789
│   ├── duckbotos-lm-studio/  ← LM Studio API server :1234
│   ├── duckbotos-brain/      ← duckbot-rag-memory (brain)
│   ├── duckbotos-computer-use/ ← Newest Desktop Control (clawdwatch-lobster-edition)
│   ├── duckbotos-browseros/  ← BrowserOS as default browser
│   ├── duckbotos-kiosk/      ← Weston + Chromium kiosk
│   ├── duckbotos-session-picker/ ← Hermes/OpenClaw/Hybrid picker
│   ├── duckbotos-hybrid/     ← Both modes + picker
│   ├── duckbotos-meta/        ← Mode meta-packages
│   └── duckbotos-branding/   ← Plymouth, MOTD, GDM theme
├── src/
│   ├── build.sh          ← ISO build entry point
│   ├── args.sh           ← Ubuntu 24.04 Noble configuration
│   └── mods/             ← live-build patches
└── scripts/
    ├── install.sh        ← DuckBotOS installer (curl|bash)
    └── install-deps.sh  ← Build dependency installer
```

## Build Modes

```bash
DUCKBOTOS_MODE=hermes   # Hermes only, dashboard at :9119
DUCKBOTOS_MODE=openclaw # OpenClaw only, openclaw-os at :18789
DUCKBOTOS_MODE=both     # Both + session picker at boot
```

## Build Requirements
- Debian/Ubuntu host (24.04 Noble or Debian Trixie)
- `live-build`, `debootstrap`, `squashfs-tools`, `xorriso`
- 50GB+ free disk space
- Root access

## Building Locally
```bash
# Install dependencies
sudo apt install live-build debootstrap squashfs-tools xorriso

# Build ISO
make deps
make iso
# Output: output/duckbotos-*.iso
```

## CI/CD

| Workflow | Repo | Fires on | What it does |
|----------|------|---------|-------------|
| `build-iso.yml` | DuckBotOS | push to main/duckbotos | Clones this repo, builds ISO, uploads artifact |
| `audit.yml` | cx-distro | push to duckbotos | Audits packages/ |
| `sync-to-duckbotos.yml` | cx-distro | push to duckbotos | Mirrors packages → DuckBotOS/main |
| `release.yml` | cx-distro | tag `v*` | Creates GitHub release |

## Important Notes

- **DO NOT** hardcode usernames in systemd service files → use `User=%h`
- **All packages** have `debian/control`, `debian/rules`, `debian/changelog`
- **Service files** are installed from `debian/*.service`
- **Postinst scripts** handle enable/start of services at install time
