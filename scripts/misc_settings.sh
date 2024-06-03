#!/bin/bash

# Source external scripts
source ./scripts/create_mplay_desktop.sh
source ./scripts/wireguard_config.sh


# Options for the Core System submenu
MISC_SETTINGS_OPTIONS=(
    1 "Add SideFX mplay to desktop       [ Finds Houdini in /opt/hfs and links mplay ]"
    2 "Install Wireguard                 [ Installs Wireguard on the system          ]" 
    3 "Save Wireguard config             [ Extracts currently stored config from /etc]"
    4 "Apply Wireguard cofnig            [ Applies specified wireguard cfg file      ]"
    5 "Back to Main Menu"
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
            2) install_wireguard ;;
            3) save_wireguard_config ;;
            4) apply_wireguard_config ;;
            5) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
