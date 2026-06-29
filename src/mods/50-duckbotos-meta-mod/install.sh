#!/bin/bash
#=================================================
# DuckBotOS Meta Package Installer Mod
# Installs all DuckBotOS packages based on DUCKBOTOS_MODE
# Forked from cxlinux-ai/cx-distro → Franzferdinan51/cx-distro
#=================================================

set -e
source /root/mods/shared.sh
source /root/mods/args.sh

DUCKBOTOS_MODE="${DUCKBOTOS_MODE:-hermes}"

print_info "========================================="
print_info "Installing DuckBotOS packages..."
print_info "Mode: $DUCKBOTOS_MODE"
print_info "========================================="

# Determine which DuckBotOS packages to install
case "$DUCKBOTOS_MODE" in
    hermes)
        print_info "Installing Hermes-only mode..."
        PACKAGES="
            duckbotos-base
            duckbotos-hermes
            duckbotos-lm-studio
            duckbotos-browseros
            duckbotos-computer-use
            duckbotos-kiosk
            duckbotos-kiosk-hermes
            duckbotos-branding
        "
        ;;
    openclaw)
        print_info "Installing OpenClaw-only mode..."
        PACKAGES="
            duckbotos-base
            duckbotos-openclaw
            duckbotos-lm-studio
            duckbotos-browseros
            duckbotos-computer-use
            duckbotos-kiosk
            duckbotos-branding
        "
        ;;
    both|hybrid)
        print_info "Installing Both/Hybrid mode..."
        PACKAGES="
            duckbotos-base
            duckbotos-hermes
            duckbotos-openclaw
            duckbotos-lm-studio
            duckbotos-browseros
            duckbotos-computer-use
            duckbotos-kiosk
            duckbotos-hybrid
            duckbotos-branding
        "
        ;;
    *)
        print_error "Unknown DuckBotOS mode: $DUCKBOTOS_MODE"
        print_error "Valid modes: hermes | openclaw | both"
        exit 1
        ;;
esac

# Install each package
for pkg in $PACKAGES; do
    print_info "Installing $pkg..."
    if dpkg -l "$pkg" >/dev/null 2>&1; then
        print_info "  $pkg already installed"
    else
        # Try to install from local packages first, then from repo
        if [ -d "/tmp/cx-distro/packages/$pkg" ]; then
            print_info "  Building $pkg from local source..."
            (cd /tmp/cx-distro/packages/$pkg && dpkg-buildpackage -us -uc -b && dpkg -i ../${pkg}_*.deb)
        else
            print_info "  $pkg not available locally — skipping (will be installed via post-install)"
        fi
    fi
done

print_ok "DuckBotOS packages installed: $DUCKBOTOS_MODE mode"
print_info "Agent dashboard will be available at:"
case "$DUCKBOTOS_MODE" in
    hermes)   print_info "  http://localhost:9119 (Hermes Web Dashboard)" ;;
    openclaw) print_info "  http://localhost:18789/plugins/openclawos (OpenClaw Workspace)" ;;
    both)     print_info "  http://localhost:8080 (DuckBotOS Session Picker)" ;;
esac