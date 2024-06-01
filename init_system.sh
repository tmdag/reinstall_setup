#!/bin/bash

# Log file
LOG_FILE="setup_log.txt"

# Set PATH
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

# Dialog dimensions
HEIGHT=20
WIDTH=90
CHOICE_HEIGHT=10

# Titles and messages
BACKTITLE="Setting up you fedora system"

# Log function
log_action() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a $LOG_FILE
}
log_action " --- APP Starting ---"

# Function to display notifications
notify() {
    local message=$1
    local expire_time=${2:-10}
    if command -v notify-send &>/dev/null; then
        notify-send "$message" --expire-time="$expire_time"
    fi
    dialog --backtitle "$BACKTITLE" --msgbox "$message" 10 120
    log_action "$message"
}

# Check if the script is run with sudo
# if [[ $EUID -ne 0 ]]; then
#    echo -e "This script purpose is to install and set up system tools, therefore it requires root password.\n\nPlease enter your password:"
#    exec sudo "$0" "$@"
#    exit 1
# fi

# Check for dialog installation
if ! rpm -q dialog &>/dev/null; then
    log_action "dialog missing on the system, installing ... "
    sudo dnf install -y dialog dialog mc || { log_action "Failed to install dialog. Exiting."; exit 1; }
    log_action "Installed dialog and midnight commander."
fi


# Source external scripts
source ./scripts/system_core.sh
source ./scripts/graphical_software.sh
source ./scripts/additional_software.sh
source ./scripts/gnome_settings.sh
source ./scripts/gnome_extensions.sh
source ./scripts/misc_settings.sh
source ./scripts/dnf_packages.sh
source ./scripts/flatpacks.sh
source ./pesonal/personal_setups.sh
source ./scripts/utilities.sh


# Options for the main menu
MAIN_OPTIONS=(
    1 "Core System                  [ Nvidia, CUDA drivers            ]"
    2 "Install GFX Software         [ Gimp, Blender etc               ]"
    3 "Install Additional Software  [ VS Code, Sublime, Chrome etc.   ]"
    4 "Gnome settings               [ window buttons, dpi etc.        ]"
    5 "Gnome extensions             [ Install Gnome Extensions        ]"
    6 "Misc settings                [ MPlay desktop                   ]"
    7 "Custom DNF packages          [ from dnf-packages.txt           ]"
    8 "Custom Flatpack packages     [ from flatpak-packages.txt       ]"
    9 "Personal setups              [ Specific for my configuration   ]"
    10 "Utilities                    [ Check log file, browse mc       ]"
    11 "Quit"
)

main_function(){
    # Main loop
    while true; do
        CHOICE=$(dialog --clear \
                    --backtitle "$BACKTITLE" \
                    --title "Please Make a Selection" \
                    --nocancel \
                    --menu "Please Choose one of the following options:" \
                    $HEIGHT $WIDTH $CHOICE_HEIGHT \
                    "${MAIN_OPTIONS[@]}" \
                    2>&1 >/dev/tty)

        clear
        case $CHOICE in
            1) core_system_menu ;;
            2) install_gfx_software;;
            3) install_additional_software ;;
            4) gnome_settings ;;
            5) gnome_extensions_menu ;;
            6) misc_settings ;;
            7) custom_dnf_packages ;;
            8) custom_flatpack_packages ;;
            9) personal_setups ;;
            10) utilitiy_tools ;;
            11) log_action "User chose to quit the script."; exit 0 ;;
            *) log_action "Invalid option selected: $CHOICE";;
        esac
    done
}


main_function