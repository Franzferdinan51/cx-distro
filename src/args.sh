#!/bin/bash
#=================================================
# DuckBotOS Build Configuration
# Forked from cxlinux-ai/cx-distro → Franzferdinan51/cx-distro
# SPDX-License-Identifier: Apache-2.0
#
# Edit this file to customize the DuckBotOS build.
# Run: ./src/build.sh (or make iso from Makefile)
#=================================================

#==========================
# Builder Environment
#==========================
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export HOME=/root
export INTERACTIVE="-y"

#==========================
# Language
#==========================
export LANG_MODE="en_US"
export LANG_PACK_CODE="en"
export LC_ALL=$LANG_MODE.UTF-8
export LC_CTYPE=$LANG_MODE.UTF-8
export LANG=$LANG_MODE.UTF-8
export LANGUAGE=$LANG_MODE:$LANG_PACK_CODE
export LANGUAGE_PACKS="language-pack-$LANG_PACK_CODE* language-pack-gnome-$LANG_PACK_CODE*"

#==========================
# OS System Information
#==========================
# Ubuntu 24.04 LTS Noble Numbat
export TARGET_UBUNTU_VERSION="noble"
export BUILD_UBUNTU_MIRROR="${BUILD_UBUNTU_MIRROR}"
export TARGET_ARCH="${ARCH:-amd64}"
export APT_CACHER_NG_URL="${APT_CACHER_NG_URL:-}"

# DuckBotOS identity
export TARGET_NAME="duckbotos"
export TARGET_BUSINESS_NAME="DuckBotOS"
export TARGET_BUILD_VERSION="0.1.0"
export TARGET_BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "duckbotos")

#===========================
# DuckBotOS Install Modes
#===========================
# Which agent mode to install: hermes | openclaw | both
# Set at build time. For ISO: default to hermes (user picks at install time for "both" mode)
export DUCKBOTOS_MODE="${DUCKBOTOS_MODE:-hermes}"

#===========================
# Packages to REMOVE during install
#===========================
# No GNOME, no Ubuntu desktop apps, no snap — this is an agent-first kiosk OS
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
    snapd \
    gnome-shell \
    gnome-session \
    gnome-control-center \
    gnome-software \
    gnome-calendar \
    gnome-weather \
    gnome-clocks \
    gnome-characters \
    gnome-connections \
    gnome-contacts \
    gnome-font-viewer \
    gnome-logs \
    gnome-maps \
    gnome-music \
    gnome-photos \
    gnome-tour \
    gnome-weather \
    yelp \
    libreoffice-* \
    thunderbird \
    firefox \
    flatpak \
    transmission-gtk \
"

#===========================
# Default apps — MINIMAL for kiosk OS
#===========================
# Only CLI tools + audio + display utilities. No GNOME apps.
export DEFAULT_APPS="
    # CLI essentials
    curl, wget, git, jq, zip, unzip, tar, gzip, bzip2, xz-utils,
    # System monitoring (agent uses these)
    htop, tree, vim, nano, rsync, ncdu, strace, lsof, net-tools, iproute2,
    iputils-ping, dnsutils, smartmontools, traceroute, whois, nmap, fastfetch,
    # Build tools
    build-essential, make, gcc, g++, dpkg-dev, pkg-config,
    # Audio (Hermes voice features)
    libportaudio2, alsa-utils, pulseaudio,
    # Display / Wayland (Weston kiosk)
    weston, xwayland, wayland-protocols, libwayland-bin,
    # Accessibility (computer-use-linux needs AT-SPI2)
    at-spi2-core, at-spi2-atk,
    # Screenshot / clipboard (computer-use-linux uses these)
    grim, wl-clipboard,
    # Python runtime (Hermes)
    python3, python3-pip, python3-venv, python3-yaml, python3-requests, python3-aiohttp,
    # Node runtime (OpenClaw)
    nodejs, npm,
"

export DEFAULT_CLI_TOOLS=""

#===========================
# Browser — BrowserOS (default browser)
#===========================
# BrowserOS installed via duckbotos-browseros mod, not here
export FIREFOX_PROVIDER="none"

#===========================
# Input method — minimal (no IME for v1)
#===========================
export INPUT_METHOD_INSTALL=""
export CONFIG_INPUT_METHOD="[('xkb', 'us')]"

#===========================
# Time Zone
#===========================
export TIMEZONE="America/New_York"

#===========================
# Weather — not needed in v1
#===========================
export CONFIG_WEATHER_LOCATION="[]"

#===========================
# Store — none (no snap/flatpak in v1)
#===========================
export STORE_PROVIDER="none"