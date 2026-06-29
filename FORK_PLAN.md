# DuckBotOS — CX Linux Fork Plan

> Forked from: `cxlinux-ai/cx-distro` → `Franzferdinan51/cx-distro`
> Build: 2026-06-29
> License: Apache 2.0 (our new code), BSL 1.1 (cxlinux-ai pipeline — free for us, converts 2032)

---

## What We Inherit (BSL 1.1 — OK for our use)

- `live-build` ISO build pipeline (Makefile, scripts/, iso/live-build/)
- All Debian packaging infrastructure (packages/*/debian/control)
- APT repository setup (apt/)
- Preseed installer config
- CI/CD (`.github/workflows/build-iso.yml`)
- AppArmor profiles, Firejail sandboxing (cx-secops)
- SBOM generation (syft + cyclonedx-cli)
- Plymouth boot themes, GDM branding (cx-branding)
- NVIDIA/AMD GPU driver packages (cx-gpu-nvidia, cx-gpu-amd)
- Tests (tests/)

## What We Replace

### 1. Base OS: Debian trixie → Ubuntu 24.04 noble

In `Makefile`:
```makefile
# BEFORE (Debian)
CODENAME := trixie

# AFTER (Ubuntu)
CODENAME := noble
```

In `iso/live-build/` config — update `--distribution` and package lists.

### 2. Meta-packages (biggest change)

| CX Linux (REPLACE) | DuckBotOS (REPLACE WITH) | Notes |
|--------------------|--------------------------|-------|
| `cx-core` | `duckbotos-base` | Core OS deps (python3, pip, venv, yaml, requests, firejail) |
| `cx-full` | SPLIT into 3 modes (see below) | |
| `cx-llm` | `duckbotos-lm-studio` | LM Studio headless instead of embedded Ollama |
| `cx-branding` | `duckbotos-branding` | DuckBotOS OS identity, Plymouth, GDM |
| (new) | `duckbotos-hermes` | Hermes agent + web dashboard :9119 |
| (new) | `duckbotos-openclaw` | OpenClaw gateway + openclaw-os plugin :18789 |
| (new) | `duckbotos-browseros` | BrowserOS as default browser |
| (new) | `duckbotos-computer-use` | Newest Desktop Control (Lobster Edition) MCP server |
| (new) | `duckbotos-meta` | Master meta-package (depends on mode package) |
| (new) | `duckbotos-kiosk` | Weston + Chromium kiosk service |
| (new) | `duckbotos-hybrid` | Both mode: depends on hermes + openclaw |

### 3. Mode Packages (what gets installed)

**Hermes-only mode:**
```
duckbotos-meta → duckbotos-base + duckbotos-hermes + duckbotos-lm-studio + duckbotos-browseros + duckbotos-computer-use + duckbotos-kiosk
```

**OpenClaw-only mode:**
```
duckbotos-meta → duckbotos-base + duckbotos-openclaw + duckbotos-lm-studio + duckbotos-browseros + duckbotos-computer-use + duckbotos-kiosk
```

**Both/Hybrid mode:**
```
duckbotos-meta → duckbotos-base + duckbotos-hermes + duckbotos-openclaw + duckbotos-lm-studio + duckbotos-browseros + duckbotos-computer-use + duckbotos-hybrid + duckbotos-kiosk
```

### 4. Replace cx-terminal (Rust) with Hermes install

CX Linux's `cx-core` depends on `ollama` (for cx-llm). We replace with:
- LM Studio headless install (our `duckbotos-lm-studio` package)
- Hermes agent install (our `duckbotos-hermes` package)

### 5. Branding changes (duckbotos-branding)

Replace all CX Linux → DuckBotOS in:
- `/etc/os-release`
- `/etc/lsb-release`
- Plymouth theme (cx-branding boot/ → DuckBotOS splash)
- GDM theme (cx-branding/usr/share/gdm/ → our theme)
- MOTD (cx-branding/etc/ → DuckBotOS MOTD)
- Wallpaper

### 6. Installer script changes

Replace `scripts/install.sh` with our own that:
1. Detects architecture (amd64/arm64)
2. Asks: Hermes / OpenClaw / Both (mode selection)
3. Adds our APT repo + key
4. `apt install duckbotos-meta` (mode auto-selected)

### 7. Keep NVIDIA GPU packages (cx-gpu-nvidia) — Duckets confirmed target machine has NVIDIA GPU
cx-gpu-nvidia brings: nvidia-driver, CUDA toolkit, nvidia-container-toolkit, GPU monitoring (nvidia-smi). LM Studio GPU inference works out of the box.

### 8. live-build config changes

In `iso/live-build/`:
- Add our packages to package list (duckbotos-meta, etc.)
- Change ISO volume: "CX Linux" → "DuckBotOS"
- Change ISO publisher: "AI Venture Holdings LLC" → "DuckBotOS"
- Update GRUB theme to DuckBotOS
- Remove cx-* packages, add duckbotos-* packages

---

## Build Dependencies (for UTM Ubuntu 24.04 VM)

```bash
apt install -y \
  live-build \
  debootstrap \
  squashfs-tools \
  xorriso \
  isolinux \
  syslinux-efi \
  grub-pc-bin \
  grub-efi-amd64-bin \
  mtools \
  dosfstools \
  dpkg-dev \
  devscripts \
  debhelper \
  fakeroot \
  gnupg \
  syft \
  cyclonedx-cli \
  python3-pip \
  wget \
  curl
```

## UTM VM Spec for ISO Build

- **OS**: Ubuntu 24.04 LTS Server (no GUI)
- **CPU**: 4 cores
- **RAM**: 8GB
- **Disk**: 64GB (minimum for ISO build)
- **Networking**: NAT
- **Build time**: ~30-60 min per ISO

## Immediate Next Steps (no VM needed yet)

1. ✅ Fork cxlinux-ai/cx-distro → Franzferdinan51/cx-distro (DONE 09:26)
2. ⏳ Study cx-distro structure (DONE — this doc)
3. ⏳ Write new debian/control files for all duckbotos-* packages
4. ⏳ Update Makefile: trixie → noble, CX Linux → DuckBotOS
5. ⏳ Set up UTM Ubuntu 24.04 VM on Mac mini
6. ⏳ Run `make deps` in VM, then `make iso`

## NVIDIA GPU note (D1 updated 2026-06-29 10:40 EDT)
Keep NVIDIA GPU drivers for v1. Target machine has NVIDIA GPU. LM Studio GPU inference supported. CPU-only fallback still builds without cx-gpu-nvidia. Skip cx-gpu-amd (AMD GPU not confirmed):
- `cx-gpu-nvidia`
- `cx-gpu-amd`

CPU-only build = smaller ISO + faster build + works on any hardware.

## License Notes

Our new code: Apache 2.0
CX Linux pipeline: BSL 1.1 (free for personal use, converts to Apache 2032)
Hermes: MIT
OpenClaw: MIT
Newest Desktop Control (Lobster Edition): TBD (check their repo)
BrowserOS: TBD (check their repo)

We write all our package code fresh. Fork the build pipeline. No BSL contamination in our source files.