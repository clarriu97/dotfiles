#!/usr/bin/env bash
# lib/detect.sh — automatic operating system and architecture detection.
# Exports: OS (macos|ubuntu|fedora), OS_RAW, ARCH, DEB_ARCH.
# Meant to be sourced.

detect_os() {
    local uname_s
    uname_s="$(uname -s)"

    if [[ "$uname_s" == "Darwin" ]]; then
        OS="macos"
        OS_RAW="macos"
        return 0
    fi

    if [[ -r /etc/os-release ]]; then
        # ID and ID_LIKE come from /etc/os-release (e.g. ID=ubuntu, ID_LIKE=debian)
        local ID="" ID_LIKE=""
        # shellcheck disable=SC1091
        . /etc/os-release
        OS_RAW="${ID:-unknown}"
        case "${ID}:${ID_LIKE}" in
            ubuntu:*|debian:*|*:*debian*|*:*ubuntu*) OS="ubuntu" ;;
            fedora:*|rhel:*|*:*fedora*|*:*rhel*)     OS="fedora" ;;
            *) OS="unknown" ;;
        esac
        return 0
    fi

    OS="unknown"
    OS_RAW="$uname_s"
}

detect_arch() {
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64|amd64)        DEB_ARCH="amd64" ;;
        i686|i386)           DEB_ARCH="i386" ;;
        aarch64|arm64)       DEB_ARCH="arm64" ;;
        *)                   DEB_ARCH="" ;;
    esac
}

detect_os
detect_arch
export OS OS_RAW ARCH DEB_ARCH
