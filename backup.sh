#!/usr/bin/env bash

rsync ~/.config/ghostty .config/
rsync ~/.config/hypr .config/
rsync ~/.config/mimeapps.list .config/
rsync ~/.config/dconf .config/

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <source_profile_directory>"
    exit 1
fi

SRC="$(realpath "$1")"

if [[ ! -d "$SRC" ]]; then
    echo "Error: source directory does not exist:"
    echo "  $SRC"
    exit 1
fi

DEST_BASE=".config/zen"
DEST_NAME="$(basename "$SRC")"
DEST="$DEST_BASE/$DEST_NAME"

mkdir -p "$DEST"

copy_if_exists() {
    local item="$1"

    if [[ -e "$SRC/$item" ]]; then
        echo "Copying: $item"
        cp -a "$SRC/$item" "$DEST/"
    else
        echo "Skipping missing: $item"
    fi
}

ITEMS=(
    "user.js"
    "prefs.js"

    "extensions"
    "browser-extension-data"

    "extension-preferences.json"
    "extension-settings.json"
    "extensions.json"

    "chrome"
    "settings"

    "containers.json"
)

for item in "${ITEMS[@]}"; do
    copy_if_exists "$item"
done

# Copy all zen-* files/directories
shopt -s nullglob

for zen_item in "$SRC"/zen-*; do
    name="$(basename "$zen_item")"
    echo "Copying: $name"
    cp -a "$zen_item" "$DEST/"
done

echo
echo "Done."
echo "Restored files copied to:"
echo "  $DEST"

rsync ~/.zshrc .
sudo rsync -a --relative \
  --exclude='etc/machine-id' \
  --exclude='etc/ssh/ssh_host_*' \
  --exclude='etc/passwd' \
  --exclude='etc/shadow' \
  --exclude='etc/group' \
  --exclude='etc/gshadow' \
  --exclude='etc/fstab' \
  --exclude='etc/resolv.conf' \
  /etc/pacman.conf \
  /etc/makepkg.conf \
  /etc/mkinitcpio.conf \
  /etc/paru.conf \
  /etc/nftables.conf \
  /etc/fstab \
  /etc/hostname \
  /etc/hosts \
  /etc/environment \
  /etc/profile \
  /etc/profile.d \
  /etc/modprobe.d \
  /etc/modules-load.d \
  /etc/sysctl.d \
  /etc/systemd \
  /etc/sudoers.d \
  /etc/X11 \
  /etc/NetworkManager \
  /etc/pipewire \
  /etc/bluetooth \
  /etc/sddm.conf \
  /etc/zsh \
  /etc/nginx \
  .
pacman -Qqe > pkglist.txt
pacman -Qqem > aurlist.txt

systemctl list-unit-files --state=enabled --no-legend |
awk '{print $1}' > enabled-services.txt
