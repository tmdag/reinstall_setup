#!/bin/bash

# Source external scripts
source ./create_mplay_desktop.sh










# Options for the Core System submenu
MISC_SETTINGS_OPTIONS=(
    1 "Add SideFX mplay to desktop       [ Finds Houdini in /opt/hfs and links mplay ]"
    3 "Back to Main Menu"
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
            3) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
