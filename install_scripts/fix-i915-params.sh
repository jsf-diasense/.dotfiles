#!/usr/bin/env bash
# fix-i915-params.sh — add i915.enable_dc=0 i915.enable_psr=0 to GRUB cmdline.
#
# Fixes the Meteor Lake eDP PHY wedge ("Failed to bring PHY A to idle") that
# hard-freezes the machine when undocking a DisplayLink dock with the lid
# closed, under sway/wlroots. enable_psr=0 stops PSR from wedging the PHY on
# exit; enable_dc=0 keeps display C-states off. Idempotent. Reboot to apply.
set -euo pipefail

GRUB=/etc/default/grub
PARAMS="i915.enable_dc=0 i915.enable_psr=0"

if grep -qE '^\s*GRUB_CMDLINE_LINUX_DEFAULT=".*i915\.enable_psr=0' "$GRUB"; then
    echo "==> already configured; nothing to do."
    exit 0
fi

echo "==> Backing up $GRUB -> ${GRUB}.bak.$(date +%Y%m%d)"
sudo cp "$GRUB" "${GRUB}.bak.$(date +%Y%m%d)"

# Uncomment the line if commented, then append params before the closing quote.
sudo sed -i 's/^#\s*\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1/' "$GRUB"
sudo sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT=".*\)"/\1 '"$PARAMS"'"/' "$GRUB"

grep GRUB_CMDLINE_LINUX_DEFAULT "$GRUB"

echo "==> Regenerating grub.cfg"
sudo update-grub

echo "Done. REBOOT to take effect."
