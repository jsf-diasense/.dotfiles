#!/bin/sh
# Workaround for sway/wlroots losing DisplayLink (evdi) outputs after resume.
#
# On wake, wlroots probes for outputs immediately, but the DisplayLink driver
# takes several seconds to reconnect the evdi monitors. wlroots sees nothing,
# and never re-adds them when they appear -> black external screens (sway itself
# stays alive and responsive). GNOME/Mutter handles the late hotplug; wlroots
# does not. Manually bouncing the VT makes wlroots re-scan its DRM connectors
# and re-attach the monitors -- this does that automatically once DisplayLink
# has reconnected.
#
# Install as: /usr/lib/systemd/system-sleep/zz-sway-evdi-rescan.sh  (root, 0755)

[ "$1" = "post" ] || exit 0

# Find the VT of the active Wayland (sway) session on seat0.
sway_vt=""
for s in $(loginctl list-sessions --no-legend 2>/dev/null | awk '{print $1}'); do
    [ "$(loginctl show-session "$s" -p Type --value 2>/dev/null)" = "wayland" ] || continue
    [ "$(loginctl show-session "$s" -p Seat --value 2>/dev/null)" = "seat0" ] || continue
    sway_vt="$(loginctl show-session "$s" -p VTNr --value 2>/dev/null)"
    break
done
[ -n "$sway_vt" ] || exit 0

# Detach so we never delay the resume transition itself.
setsid sh -c '
    vt='"$sway_vt"'
    # Wait up to ~30s for a DisplayLink (evdi) monitor to reconnect.
    found=0; i=0
    while [ "$i" -lt 360 ]; do
        for st in /sys/class/drm/card*-DVI-I-*/status; do
            [ -e "$st" ] || continue
            if [ "$(cat "$st")" = "connected" ]; then found=1; break; fi
        done
        [ "$found" = 1 ] && break
        i=$((i + 1)); sleep 0.5
    done
    [ "$found" = 1 ] || exit 0          # no DisplayLink monitors -> nothing to fix
    sleep 2                              # let DisplayLink finish the modeset
    # Only bounce if sway is the VT currently on screen, so we do not yank a
    # user who deliberately switched to a text console.
    active="$(cat /sys/class/tty/tty0/active 2>/dev/null | tr -dc 0-9)"
    [ "$active" = "$vt" ] || exit 0
    chvt 63 && sleep 1 && chvt "$vt"
' >/dev/null 2>&1 </dev/null &

exit 0
