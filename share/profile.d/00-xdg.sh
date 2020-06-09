#!/bin/sh
## 00-xdg.sh - initializes XDG directory variables
#
# See profile(7) for details.
#
# XDG_{BINARY,LIBRARY}_HOME are extensions.
# ~/.local/bin is used by other programs like `pip`, however.
#

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

if [ -d "/run/user/$(id -u)" ]; then
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
else
    export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}"
fi

export XDG_BINARY_HOME="${XDG_BINARY_HOME:-$HOME/.local/bin}"
export XDG_LIBRARY_HOME="${XDG_LIBRARY_HOME:-$HOME/.local/lib}"

# No use in following this include while linting.
# shellcheck disable=SC1090
[ -f "${XDG_CONFIG_HOME}/user-dirs.dirs" ] && . "${XDG_CONFIG_HOME}/user-dirs.dirs"
