#!/usr/bin/env bash

set -e

HYPRBUNTU_SETUP_PATH="$HOME/.local/bin"
# mkdir -p "$HYPRBUNTU_SETUP_PATH"
# curl -o "$HYPRBUNTU_SETUP_PATH/setup-hyprbuntu.sh" "https://gitlab.com/kralos/hyprbuntu/-/raw/main/setup-hyprbuntu.sh"
# chmod o+x "$HYPRBUNTU_SETUP_PATH/setup-hyprbuntu.sh"
NVIDIA_SETUP=true \
	BUILD_DIR="$HOME/.hyprbuntu" \
	THEME_PREF=dark \
	NOTIFICATION_DAEMON_PREF=swaync \
	HYPRPAPER_SETUP=true \
	HYPRLOCK_SETUP=true \
	HYPRIDLE_SETUP=true \
	HYPRSHOT_SETUP=true \
	SWAYOSD_SETUP=true \
	THUNAR_SETUP=true \
	WAYBAR_SETUP=true \
	TUIGREET_SETUP=false \
	"$HYPRBUNTU_SETUP_PATH/setup-hyprbuntu.sh"

# now install personal apps / dot files and preferences

