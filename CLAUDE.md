# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for an Ubuntu + sway (Wayland) setup on a ThinkPad (Intel Meteor Lake iGPU + NVIDIA dGPU,
DisplayLink dock). Managed with GNU stow targeting `$HOME`:

```sh
cd ~/.dotfiles && stow .
```

**Files here are live.** Stow symlinks everything into `$HOME`, so editing a file in this repo edits the
running configuration immediately — there is no build or deploy step. After changing the sway config, apply it
with `swaymsg reload`.

`.stow-local-ignore` lists what stow must NOT symlink into `$HOME` (README, install_scripts, this file, VCS
files). Anything added to the repo root that isn't a real dotfile needs an entry there.

## Layout

- `.config/` — per-app configs: `sway` (window manager, the center of the setup), `kitty`, `tmux`, `kanshi`
  (dock/monitor profiles), `wireplumber`, `Code`/`VSCodium`. `hypr` is a leftover from an abandoned hyprland
  attempt; sway is what's in use.
- `.local/bin/` — user scripts (screenshot, lid check, keyboard toggle, etc.). New scripts must be `chmod +x`.
- `install_scripts/` — idempotent machine-bootstrap scripts, not stowed. `setup-sway.sh` installs the full
  package stack and documents which package serves which keybinding/script.
- `.zshrc`, `.bashrc` — shell config; `.zshrc` is where `~/.local/bin` gets added to `PATH`.

## Gotchas

- **sway's environment is not the shell's.** sway does not read `.zshrc`, so its `PATH` lacks `~/.local/bin`.
  The launcher works around this: `set $menu PATH="$HOME/.local/bin:$PATH" wmenu-run` in the sway config.
  Anything else sway `exec`s from `.local/bin` needs a full path or the same prefix.
- **Some fixes live outside this repo** in root-owned files and are only documented in the README: the
  `i915.enable_dc=0` kernel cmdline in `/etc/default/grub`, and a systemd-sleep hook symlinked into
  `/usr/lib/systemd/system-sleep/`. Don't expect to find them here; don't try to stow them.
- The README's hardware/suspend notes (DisplayLink black-screen-after-suspend fixes, clamshell mode) are the
  history behind several scripts and settings — read it before touching suspend/display-related config.
