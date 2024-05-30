#!/bin/bash

# Set PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# Dialog dimensions
HEIGHT=20
WIDTH=90
CHOICE_HEIGHT=10

# Titles and messages
BACKTITLE="Post install system setup THE VFX Mentor"
TITLE="Please Make a Selection"
MENU="Please Choose one of the following options:"

# Log file
LOG_FILE="setup_log.txt"

# Log function
log_action() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a $LOG_FILE
}

# Function to display notifications
notify() {
    local message=$1
    local expire_time=${2:-10}
    if command -v notify-send &>/dev/null; then
        notify-send "$message" --expire-time="$expire_time"
    fi
    log_action "$message"
}

# Check for dialog installation
if ! rpm -q dialog &>/dev/null; then
    sudo dnf install -y dialog || { log_action "Failed to install dialog. Exiting."; exit 1; }
    log_action "Installed dialog."
fi

# Source external scripts
source ./scripts/system_core.sh
source ./scripts/graphical_software.sh
source ./scripts/additional_software.sh
source ./scripts/gnome_settings.sh
source ./scripts/misc_settings.sh
source ./scripts/dnf_packages.sh
source ./scripts/flatpacks.sh
source ./pesonal/personal_setups.sh


# Options for the main menu
MAIN_OPTIONS=(
    1 "Core System"
    2 "Install GFX Software"
    3 "Install Additional Software"
    4 "Gnome settings"
    5 "Misc settings"
    6 "Custom DNF packages"
    7 "Custom Flatpack packages"
    8 "Personal setups"
    9 "Quit"
)

main_function(){
    # Main loop
    while true; do
        CHOICE=$(dialog --clear \
                    --backtitle "$BACKTITLE" \
                    --title "$TITLE" \
                    --nocancel \
                    --menu "$MENU" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${MAIN_OPTIONS[@]}" \
                    2>&1 >/dev/tty)

        clear
        case $CHOICE in
            1) core_system_menu ;;
            2) install_gfx_software;;
            3) install_additional_software ;;
            4) gnome_settings ;;
            5) misc_settings ;;
            6) custom_dnf_packages ;;
            7) custom_flatpack_packages ;;
            8) personal_setups ;;
            9) log_action "User chose to quit the script."; exit 0 ;;
            *) log_action "Invalid option selected: $CHOICE";;
        esac
    done
}


main_function