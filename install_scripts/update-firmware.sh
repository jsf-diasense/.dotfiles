#!/usr/bin/env bash
# update-firmware.sh — update System Firmware (BIOS) and EC via fwupd/LVFS.
#
# WHY: this ThinkPad P1 Gen 7 (Meteor Lake + NVIDIA) hard-froze on lid-open
# after the eDP panel had been powered off, and on resume from s2idle — both
# hitting the same i915 kernel bug:
#     i915 *ERROR* Failed to bring PHY A to idle.
#     i915 *ERROR* [CRTC:150:pipe A] flip_done timed out
# Upstream i915 maintainers (Jani Nikula / Imre Deak) identified the root cause
# as BIOS/FW leaving the eDP PHY MSGBUS in a broken state. Updating the BIOS
# from 1.10 to 1.21 (which pulls in CPU microcode updates in 1.15/1.19 and a
# display-dock fix in 1.20) resolved the wedge on this machine.
#
# Idempotent. Requires AC + charged battery. Reboot to flash. Safe to re-run.
set -euo pipefail

# Make sure fwupd is alive.
sudo systemctl enable --now fwupd.service

# Pull the latest LVFS metadata.
fwupdmgr refresh || true

# Apply available firmware updates (BIOS + EC). fwupd schedules the flash for
# the next reboot; it will prompt for confirmation. No-op if already current.
fwupdmgr update || echo "==> No firmware updates pending (already on latest)."

echo "==> Current System Firmware:"
fwupdmgr get-devices 2>/dev/null | grep -A3 'System Firmware' | head -8

echo
echo "Done. REBOOT to apply any firmware updates that fwupd queued."
echo "After reboot, verify with:"
echo "  cat /sys/class/dmi/id/bios_version    # expect N48ET34W (1.21) or newer"