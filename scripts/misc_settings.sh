#!/bin/bash

# Source external scripts
source ./scripts/create_mplay_desktop.sh
source ./scripts/wireguard_config.sh
source ./scripts/davinci_resolve_fix.sh

# Options for the Core System submenu
MISC_SETTINGS_OPTIONS=(
    1 "Add SideFX mplay to desktop       [ Finds Houdini in /opt/hfs and links mplay ]"
    2 "DaVinci Resolve fix               [ Post installation fix for fedora          ]"
    3 "Install Wireguard                 [ Installs Wireguard on the system          ]" 
    4 "Save Wireguard config             [ Extracts currently stored config from /etc]"
    5 "Apply Wireguard cofnig            [ Applies specified wireguard cfg file      ]"
    6 "Back to Main Menu"
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
            3) install_wireguard ;;
            4) save_wireguard_config ;;
            5) apply_wireguard_config ;;
            6) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
