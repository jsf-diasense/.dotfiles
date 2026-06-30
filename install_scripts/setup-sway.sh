#!/usr/bin/env bash
# setup-sway.sh — install everything needed to run Jorge's sway setup.
#
# Derived from ~/.config/sway/config and the local scripts it calls
# (toggle-kb, check-lid.sh, sway-screenshot, status.sh).
# Safe to re-run. The dotfiles themselves are applied separately with:
#     cd ~/.dotfiles && stow .
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing core packages from the Ubuntu repos"
sudo apt-get update
sudo apt-get install -y \
  sway swaybg swayidle swaylock sway-notification-center \
  wmenu kanshi \
  xdg-desktop-portal-gtk xdg-desktop-portal-wlr \
  kitty tmux \
  wireplumber brightnessctl \
  network-manager network-manager-applet \
  grim slurp wl-clipboard jq libnotify-bin acpi \
  libglib2.0-bin dbus-bin gnome-settings-daemon \
  ckb-next
#  sway stack:   compositor + bg/idle/lock + swaync notifications + wmenu launcher + kanshi
#  portals:      file pickers / screencast for wayland apps (seen running in the journal)
#  kitty/tmux:   $term and the tmux sessions bound to $mod+Return / $mod+e
#  wireplumber:  wpctl volume keys (XF86Audio*)
#  brightnessctl:XF86MonBrightness* keys
#  network:      nmtui ($mod+Shift+i) + nm-applet tray icon
#  grim/slurp/wl-clipboard/jq/libnotify: the sway-screenshot script + toggle-kb
#  acpi:         check-lid.sh
#  libglib2.0-bin (gsettings) + dbus-bin (dbus-update-activation-environment) + gnome-settings-daemon:
#                the idle/suspend gsettings lines and GTK-app launch fix
#  ckb-next:     Corsair keyboard driver (remaps the G1 keys)

echo "==> Firefox as a real .deb (never snap)"
if [ -x "$here/remove-firefox-snap.sh" ]; then
  bash "$here/remove-firefox-snap.sh" || echo "   (firefox step had non-fatal errors; continuing)"
fi

echo "==> VS Code (Microsoft apt repo)  [bound to \$mod+c]"
if ! command -v code >/dev/null 2>&1; then
  sudo apt-get install -y wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y code
fi

echo "==> nwg-displays (layout GUI — design aid for kanshi profiles)"
if ! command -v nwg-displays >/dev/null 2>&1; then
  sudo apt-get install -y nwg-displays 2>/dev/null \
    || echo "   NOTE: not in apt here — install from https://github.com/nwg-piotr/nwg-displays"
fi

# ---- Manual / not-in-apt bits (printed, not auto-installed) ----------------
echo
echo "==> Manual steps still needed:"

command -v obsidian >/dev/null 2>&1 \
  || echo "  - Obsidian: download the .deb from https://obsidian.md/download, then 'sudo apt install ./obsidian*.deb'  [\$mod+Shift+o]"

command -v bluetui >/dev/null 2>&1 \
  || echo "  - bluetui:  'cargo install bluetui' (needs rustup) or drop a release binary in ~/.local/bin  [\$mod+Shift+p]"

echo "  - DisplayLink dock (office): 'sudo apt install evdi-dkms' + the DisplayLink"
echo "    driver .run from https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu"
echo "    (see ~/.dotfiles/README.md for the suspend/black-screen notes)"

echo "  - Login manager: pick the 'Sway' session in GDM (gdm3) at login."

echo
echo "==> Applying the dotfiles (GNU stow)"
echo "    cd ~/.dotfiles && stow ."
echo
echo "Done. Log out, choose 'Sway' in GDM, log back in."
