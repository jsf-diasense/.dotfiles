# Dotfiles
Managed with GNU stow.

### Changes
I parted from a clean Ubuntu 26.04 installation. I had to compile hyprland from source with the [hyprbuntu](https://gitlab.com/kralos/hyprbuntu) script. Then ran it with the `.local/bin/my-hyprbuntu.sh` script.

Then, decided to screw hyprland and use sway instead, since I've already configured i3 in the past. That turned out to be a much better idea. Since now I can just use it fine.
I installed kanshi from apt-get to make the dock work.

### Sway + DisplayLink black screen after suspend
On this ThinkPad (Intel Meteor Lake iGPU + NVIDIA dGPU, DisplayLink dock for the
external monitors) sway came back to a black screen after suspend/resume, and I
had to power-cycle. Two separate causes, two fixes:

1. **Intel i915 display resume bug.** On wake the i915 driver intermittently
   failed to restore the display PLL/pipe state (`DPLL hw state mismatch` /
   `pipe state doesn't match` in `dmesg`). Fixed by disabling the display deep
   power states via the kernel cmdline:
   ```
   # /etc/default/grub -> GRUB_CMDLINE_LINUX="i915.enable_dc=0"
   sudo update-grub && reboot
   ```
   (NOT in this repo — it's a root-owned system file. Noted here so I remember.)

2. **wlroots loses the DisplayLink monitors on resume.** sway/wlroots stays
   alive but ends up with zero outputs: on wake it probes for displays before
   the DisplayLink driver finishes reconnecting the evdi monitors (which takes
   ~7-15s), and never re-adds them. GNOME/Mutter handles the late hotplug;
   wlroots does not. A VT switch away-and-back forces wlroots to re-scan its DRM
   connectors and re-attach the monitors. `.local/bin/sway-evdi-rescan.sh` does
   that automatically: it's a systemd-sleep `post` hook that waits for a
   DisplayLink monitor to reconnect, then bounces the VT (only if sway is the
   active VT, so text consoles / dock-less suspends are left alone).

   It must run from `/usr/lib/systemd/system-sleep/`, so after stowing, symlink
   it there (root-owned symlink pointing at the stowed file):
   ```
   sudo ln -s ~/.local/bin/sway-evdi-rescan.sh \
     /usr/lib/systemd/system-sleep/zz-sway-evdi-rescan.sh
   ```

### Tmux
Follow the guide in [tpm](https://github.com/tmux-plugins/tpm)

### Clamshell Mode
I think this should be enough to fix the issue of the outputs.
https://github.com/swaywm/sway/wiki#clamshell-mode