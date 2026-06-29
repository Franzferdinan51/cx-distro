#!/bin/bash
#=================================================
# DuckBotOS Packages Installer Mod
# Clones and builds DuckBotOS packages from the fork
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

# Clone the DuckBotOS packages repo (if not already present)
if [ ! -d "/tmp/cx-distro" ]; then
    print_info "Cloning DuckBotOS fork from GitHub..."
    git clone --depth=1 --branch duckbotos \
        https://github.com/Franzferdinan51/cx-distro \
        /tmp/cx-distro
fi

# Build all DuckBotOS packages
print_info "Building DuckBotOS packages..."
cd /tmp/cx-distro/packages

# Build base package first (everything depends on it)
for pkg in duckbotos-base duckbotos-branding; do
    if [ -d "$pkg" ]; then
        print_info "  Building $pkg..."
        (cd "$pkg" && dpkg-buildpackage -us -uc -b 2>&1) || print_warn "  $pkg build failed, skipping"
    fi
done

# Install base packages
for deb in /tmp/cx-distro/packages/*.deb; do
    [ -f "$deb" ] || continue
    pkg=$(dpkg-deb -f "$deb" Package)
    case "$pkg" in
        duckbotos-base|duckbotos-branding)
            print_info "  Installing $pkg..."
            dpkg -i "$deb" || apt-get install -f -y
            ;;
    esac
done

# Build agent-specific packages
for pkg in duckbotos-hermes duckbotos-openclaw duckbotos-lm-studio \
           duckbotos-browseros duckbotos-computer-use duckbotos-cua-bridge duckbotos-kiosk \
           duckbotos-kiosk-hermes duckbotos-session-picker \
           duckbotos-meta duckbotos-hybrid \
           duckbotos-brain; do
    if [ -d "$pkg" ]; then
        print_info "  Building $pkg..."
        (cd "$pkg" && dpkg-buildpackage -us -uc -b 2>&1) || print_warn "  $pkg build failed, skipping"
    fi
done

# Install based on mode
print_info "Installing packages for mode: $DUCKBOTOS_MODE"
for deb in /tmp/cx-distro/packages/*.deb; do
    [ -f "$deb" ] || continue
    pkg=$(dpkg-deb -f "$deb" Package)
    
    # Check if package matches the current mode
    install=false
    case "$DUCKBOTOS_MODE" in
        hermes)
            case "$pkg" in
                duckbotos-hermes|duckbotos-lm-studio|duckbotos-browseros|duckbotos-computer-use|duckbotos-cua-bridge|duckbotos-kiosk|duckbotos-kiosk-hermes|duckbotos-brain)
                    install=true
                    ;;
            esac
            ;;
        openclaw)
            case "$pkg" in
                duckbotos-openclaw|duckbotos-lm-studio|duckbotos-browseros|duckbotos-computer-use|duckbotos-cua-bridge|duckbotos-kiosk|duckbotos-brain)
                    install=true
                    ;;
            esac
            ;;
        both|hybrid)
            # Install all packages for both mode
            install=true
            ;;
    esac
    
    if $install; then
        print_info "  Installing $pkg..."
        dpkg -i "$deb" || apt-get install -f -y
    fi
done

print_ok "DuckBotOS packages installed for mode: $DUCKBOTOS_MODE"