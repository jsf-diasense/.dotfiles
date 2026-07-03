#!/usr/bin/env bash
# fix-intel-xe-driver.sh — switch the Intel Meteor Lake iGPU from i915 to the xe driver.
#
# WHY: On this ThinkPad (Meteor Lake, hybrid Intel + NVIDIA, external monitors via
# a DisplayLink/EVDI dock) running sway, UNPLUGGING THE DOCK — especially with the
# lid closed, so the laptop panel eDP-1 had been powered off — made wlroots try to
# cold-start the eDP PHY and hit an i915 kernel bug:
#     i915 *ERROR* Failed to bring PHY A to idle
#     i915 *ERROR* [CRTC:150:pipe A] flip_done timed out   (C10 PLL reads back all-zeros)
# The compositor then wedged in-kernel: black screen, dead TTYs, only a hard reboot
# recovered. Reproduced on kernels 7.0.0-14 and -22. GNOME/Mutter survived it, sway
# did not, and i915.enable_dc=0 did NOT help.
#
# FIX: drive the Intel GPU with the newer `xe` driver instead of `i915` (xe rewrote
# this generation's display/PHY code). Done via kernel cmdline force_probe in GRUB.
# After a reboot:  lspci -nnk -d ::0300  should show  "Kernel driver in use: xe".
#
# Safe to re-run (idempotent). Requires a REBOOT to take effect.
# To undo:  sudo cp /etc/default/grub.bak /etc/default/grub && sudo update-grub
set -euo pipefail

GRUB=/etc/default/grub

# Intel display controller PCI device id (e.g. 7d55 for Meteor Lake-P). Detected,
# with a fallback to the known id for this machine.
pciid="$(lspci -nn -d ::0300 2>/dev/null | grep -io '8086:[0-9a-f]\{4\}' | head -n1 | cut -d: -f2)"
pciid="${pciid:-7d55}"
params="i915.force_probe=!${pciid} xe.force_probe=${pciid}"

if grep -q "xe.force_probe=${pciid}" "$GRUB"; then
    echo "==> xe force_probe already configured in $GRUB; nothing to do."
    exit 0
fi

echo "==> Backing up $GRUB -> ${GRUB}.bak"
sudo cp "$GRUB" "${GRUB}.bak"

echo "==> Appending '$params' to GRUB_CMDLINE_LINUX_DEFAULT"
# Insert the params just before the closing quote of the DEFAULT line.
sudo sed -i "s|^\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"|\1 ${params}\"|" "$GRUB"

grep GRUB_CMDLINE_LINUX_DEFAULT "$GRUB"

echo "==> Regenerating grub.cfg"
sudo update-grub

echo
echo "Done. REBOOT, then verify with:  lspci -nnk -d ::0300 | grep 'in use'"
echo "(expect: Kernel driver in use: xe)"
