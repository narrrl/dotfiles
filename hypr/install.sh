#!/bin/bash

# Set paths
CONFIG_DIR="$HOME/.config/hypr"
BACKUP_DIR="$CONFIG_DIR/hyprlock-backup-$(date +%Y%m%d%H%M%S)"
REPO_URL="https://github.com/Tamarindtype/googlish-hyprlock-theme.git"
TEMP_DIR="$(mktemp -d)"

read -p "Do you want to see every command executed? [y/N]: " choice
choice=${choice,,}

if [[ "$choice" == "y" ]]; then
    SHOW_COMMANDS=true
else
    SHOW_COMMANDS=false
fi

run_cmd() {
    local desc="$1"
    local cmd="$2"

    if [[ "$SHOW_COMMANDS" == true ]]; then 
        echo -e "\n$desc"
        echo "-> $cmd"
        read -p "Run command? [Y/n]: " confirm
        confirm=${confirm,,} 

        if [[ "$confirm" == "n" ]]; then
            echo "⏭ Skipped."
        else
            eval "$cmd"
        fi
    else
        eval "$cmd"
    fi
}

# Backup existing config
if [ -d "$CONFIG_DIR/hyprlock" ] || [ -f "$CONFIG_DIR/hyprlock.conf" ]; then
    read -p "Do you want to create a backup of your config? [Y/n]: " choice
    choice=${choice,,}

    if [[ "$choice" != "n" ]]; then
        run_cmd "Creating backup folder" "mkdir -p \"$BACKUP_DIR\""
        
        if [ -d "$CONFIG_DIR/hyprlock" ]; then
            run_cmd "Backing up folder" "mv \"$CONFIG_DIR/hyprlock\" \"$BACKUP_DIR/\""
        fi

        if [ -f "$CONFIG_DIR/hyprlock.conf" ]; then
            run_cmd "Backing up file" "mv \"$CONFIG_DIR/hyprlock.conf\" \"$BACKUP_DIR/\""
        fi
    fi
else
    echo "No existing hyprlock config found. Skipping backup."
fi

# Clone the repo
run_cmd "Cloning repository..." "git clone \"$REPO_URL\" \"$TEMP_DIR\""

# Move files
run_cmd "Creating config directory" "mkdir -p \"$CONFIG_DIR\""

if [ -d "$TEMP_DIR/hyprlock" ]; then
    run_cmd "Moving hyprlock folder" "mv \"$TEMP_DIR/hyprlock\" \"$CONFIG_DIR/\""
fi

if [ -f "$TEMP_DIR/hyprlock.conf" ]; then
    run_cmd "Moving hyprlock.conf" "mv \"$TEMP_DIR/hyprlock.conf\" \"$CONFIG_DIR/\""
fi

# Make scripts executable
if [ -d "$CONFIG_DIR/hyprlock" ]; then
    run_cmd "Making scripts executable..." "chmod +x \"$CONFIG_DIR/hyprlock\"/*.sh"
fi

# Optional: Run hyprlock
run_cmd "Running Hyprlock" "hyprlock"

read -p "Do you want to install the 'hyprlock-change-wallpaper' command? [Y/n]: " choice
choice=${choice,,}

if [[ "$choice" != "n" ]]; then
    run_cmd "Installing hyprlock-change-wallpaper shortcut" "sudo ln -sf $CONFIG_DIR/hyprlock/change_wallpaper.sh /usr/local/bin/hyprlock-change-wallpaper"
    run_cmd "Make command runable" "chmod +x $CONFIG_DIR/hyprlock/change_wallpaper.sh"

    if command -v hyprlock-change-wallpaper &>/dev/null; then
        echo "hyprlock-change-wallpaper was succesfully installed"
    else
        echo "Error while installing hyprlock-change-wallpaper."
    fi
else
    echo "⏭ installation of hyprlock-change-wallpaper skipped"
fi

# Cleanup
run_cmd "Cleaning up temp files..." "rm -rf \"$TEMP_DIR\""
