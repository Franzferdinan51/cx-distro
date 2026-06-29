#!/bin/bash
# DuckBotOS Installer Script
# Forked from cxlinux-ai/cx-distro → Franzferdinan51/cx-distro
# Usage: curl -fsSL https://duckbotos.dev/install.sh | bash
# Or:    bash install.sh

set -e

VERSION="0.1.0"
REPO="Franzferdinan51/cx-distro"
INSTALL_MODES="hermes openclaw both"
SUPPORTED_ARCH=$(uname -m)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[DuckBotOS]${NC} $1"; }
warn() { echo -e "${YELLOW}[DuckBotOS]${NC} WARNING: $1"; }
err() { echo -e "${RED}[DuckBotOS]${NC} ERROR: $1" >&2; }

# Detect if running in live environment vs installed system
detect_environment() {
    if whoami | grep -q "^root"; then
        if [ -d /root/etc ] || mount | grep -q "casper"; then
            echo "live"
        else
            echo "installed"
        fi
    else
        echo "user"
    fi
}

# Detect architecture
detect_arch() {
    case $(uname -m) in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        arm64)   echo "arm64" ;;
        *)       echo "" ;;
    esac
}

# Check prerequisites
check_prereqs() {
    local env=$(detect_environment)
    log "Detected environment: $env"

    if [ "$env" = "user" ]; then
        err "This script must be run as root (sudo)."
        exit 1
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
        err "apt-get not found. This script requires Debian/Ubuntu."
        exit 1
    fi

    if [ "$(detect_arch)" = "" ]; then
        err "Unsupported architecture: $(uname -m)"
        exit 1
    fi

    log "Architecture: $(detect_arch)"
}

# Add DuckBotOS APT repository
add_repo() {
    log "Adding DuckBotOS APT repository..."

    local codename=$(lsb_release -cs 2>/dev/null || echo "noble")
    local sources_list="/etc/apt/sources.list.d/duckbotos.list"

    echo "deb [arch=$(detect_arch) signed-by=/usr/share/keyrings/duckbotos-archive-keyring.gpg] \
https://apt.duckbotos.dev/ $(codename) main" | sudo tee "$sources_list" > /dev/null

    # Import repository key
    sudo mkdir -p /usr/share/keyrings
    curl -fsSL https://apt.duckbotos.dev/duckbotos-archive-keyring.gpg | \
        sudo gpg --dearmor -o /usr/share/keyrings/duckbotos-archive-keyring.gpg

    sudo apt-get update -qq
    log "Repository added."
}

# Interactive mode selection
select_mode() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           DuckBotOS — Agent Selection                   ║"
    echo "╠══════════════════════════════════════════════════════════╣"
    echo "║                                                          ║"
    echo "║  Choose your agent experience:                           ║"
    echo "║                                                          ║"
    echo "║  [1] Hermes          — NousResearch agent, web dashboard ║"
    echo "║                         at :9119. Best for: chat-first,  ║"
    echo "║                         skills, voice, messaging.        ║"
    echo "║                                                          ║"
    echo "║  [2] OpenClaw        — OpenClaw gateway + openclaw-os   ║"
    echo "║                         plugin at :18789. Best for:      ║"
    echo "║                         multi-channel, web workspace.    ║"
    echo "║                                                          ║"
    echo "║  [3] Both            — Install both. Pick at login:     ║"
    echo "║                         Hermes / OpenClaw / Hybrid (GNOME║"
    echo "║                         with both agents in taskbar).    ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""
    read -p "Select [1/2/3] (default: 1): " mode_choice
    case "${mode_choice:-1}" in
        1) echo "hermes" ;;
        2) echo "openclaw" ;;
        3) echo "both" ;;
        *) echo "hermes" ;;
    esac
}

# Install DuckBotOS
do_install() {
    local mode="${1:-hermes}"
    check_prereqs

    log "Installing DuckBotOS ($mode mode)..."
    log "Version: $VERSION"
    echo ""

    # Add repo
    add_repo

    # Select mode if not specified
    if [ -z "$mode" ]; then
        mode=$(select_mode)
    fi

    log "Selected mode: $mode"
    echo ""

    # Install the appropriate meta-package
    case "$mode" in
        hermes)
            log "Installing Hermes agent..."
            sudo apt-get install -y duckbotos-hermes
            ;;
        openclaw)
            log "Installing OpenClaw agent..."
            sudo apt-get install -y duckbotos-openclaw
            ;;
        both|hybrid)
            log "Installing Both modes (Hermes + OpenClaw + session picker)..."
            sudo apt-get install -y duckbotos-hybrid
            ;;
        *)
            err "Unknown mode: $mode"
            exit 1
            ;;
    esac

    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    log "✅ DuckBotOS installed successfully!"
    echo ""
    echo "  Mode:        $mode"
    echo "  Agent:       $([ "$mode" = "hermes" ] && echo "Hermes (localhost:9119)" || ([ "$mode" = "openclaw" ] && echo "OpenClaw (localhost:18789)" || echo "Both — pick at login"))"
    echo ""
    echo "  To start:    sudo systemctl start duckbotos-kiosk"
    echo "  To enable:   sudo systemctl enable duckbotos-kiosk"
    echo "  Config:      /etc/duckbotos/"
    echo "  Logs:        journalctl -u duckbotos-*"
    echo ""
    echo "  After reboot, DuckBotOS will boot directly into the agent."
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

# Main
case "${1:-}" in
    --help|-h)
        echo "DuckBotOS Installer"
        echo ""
        echo "Usage: $(basename $0) [mode]"
        echo ""
        echo "Modes: hermes (default) | openclaw | both"
        echo ""
        echo "Or pipe from web:"
        echo "  curl -fsSL https://duckbotos.dev/install.sh | bash"
        echo "  curl -fsSL https://duckbotos.dev/install.sh | bash -s hermes"
        echo ""
        ;;
    *)
        do_install "${1:-}"
        ;;
esac