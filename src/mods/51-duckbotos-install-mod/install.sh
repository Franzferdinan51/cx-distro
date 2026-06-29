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
           duckbotos-kiosk-hermes duckbotos-kiosk-openclaw duckbotos-session-picker \
           duckbotos-meta duckbotos-hybrid \
           duckbotos-brain; do
    if [ -d "$pkg" ]; then
        print_info "  Building $pkg..."
        (cd "$pkg" && dpkg-buildpackage -us -uc -b 2>&1) || print_warn "  $pkg build failed, skipping"
    fi
done

# Pre-register all .deb files with dpkg's database so apt's resolver can find them
# when the meta-package depends on them recursively
print_info "  Registering built packages with dpkg database..."
for deb in /tmp/cx-distro/packages/*.deb; do
    [ -f "$deb" ] || continue
    dpkg -i "$deb" 2>/dev/null || true
done
apt-get install -f -y 2>&1 | tail -5 || true

# Install based on mode — use the appropriate meta-package, let apt resolve Depends
print_info "Installing DuckBotOS meta-package for mode: $DUCKBOTOS_MODE"
case "$DUCKBOTOS_MODE" in
    hermes)
        META_PKG="duckbotos-mode-hermes"
        ;;
    openclaw)
        META_PKG="duckbotos-mode-openclaw"
        ;;
    both|hybrid)
        META_PKG="duckbotos-mode-hybrid"
        ;;
    *)
        print_warn "  Unknown mode '$DUCKBOTOS_MODE', defaulting to duckbotos-meta (Hermes)"
        META_PKG="duckbotos-meta"
        ;;
esac

print_info "  Installing $META_PKG (apt will resolve all Depends recursively)..."
DEBIAN_FRONTEND=noninteractive apt-get install -y "$META_PKG" 2>&1 | tail -10 || {
    print_warn "  Meta install failed, falling back to dpkg -i on built debs"
    # Fallback: manual install of all built packages
    for deb in /tmp/cx-distro/packages/*.deb; do
        [ -f "$deb" ] || continue
        dpkg -i "$deb" 2>/dev/null || apt-get install -f -y 2>&1 | tail -3
    done
}

print_ok "DuckBotOS meta-package $META_PKG installed (mode: $DUCKBOTOS_MODE)"

# Mark which mode is the default so later code can read it
echo "$META_PKG" > /etc/duckbotos/installed-mode
