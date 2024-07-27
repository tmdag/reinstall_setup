#!/bin/bash

# Source external scripts
source ./scripts/create_mplay_desktop.sh
source ./scripts/wireguard_config.sh
source ./scripts/davinci_resolve_fix.sh

peek_wayland(){
    clear
    log_action "Installing Blender"
    local DESKTOP_ENTRY="/usr/share/applications/com.uploadedlobster.peek.desktop"
    sudo cp "$DESKTOP_ENTRY" "${DESKTOP_ENTRY}.bak"
    sudo sed -i 's/^Exec=peek$/Exec=env GDK_BACKEND=x11 peek/' "$DESKTOP_ENTRY"
    notify "Desktop entry modified to add Wayland support."
}

# Options for the Core System submenu
MISC_SETTINGS_OPTIONS=(
    1 "Add SideFX mplay to desktop       [ Finds Houdini in /opt/hfs and links mplay ]"
    2 "DaVinci Resolve fix               [ Post installation fix for fedora          ]"
    3 "Peek Wayland fix                  [ Adds Wayland support for Peek             ]"
    4 "Install Wireguard                 [ Installs Wireguard on the system          ]" 
    5 "Save Wireguard config             [ Extracts currently stored config from /etc]"
    6 "Apply Wireguard cofnig            [ Applies specified wireguard cfg file      ]"
    7 "Back to Main Menu"
)

# Function to display the Core System submenu
misc_settings() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "Misc Settings" \
                        --menu "Select one of the following options:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${MISC_SETTINGS_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) add_mplay_app ;;
            2) fix_davinci_resolve ;;
            3) peek_wayland ;;
            4) install_wireguard ;;
            5) save_wireguard_config ;;
            6) apply_wireguard_config ;;
            7) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
