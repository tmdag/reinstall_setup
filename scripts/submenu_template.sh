#!/bin/bash


menu_option_A(){
    clear
	log_action "menu option A triggered"

    # Action for menu optionA

    # capture log using "&>> $LOG_FILE"
    # sudo dnf install -y myapp &>> $LOG_FILE

	notify  "menu option A finished"
}

menu_option_B(){
    clear
    log_action "menu option B triggered"

    # Bction for menu optionB

    notify  "menu option B finished"
}


################################################################################################
# Menu constract
GNOME_SETTINGS_OPTIONS=(
    1 "Menu A selection              [ Some amazing things to happen A ]"
    2 "Menu B selection              [ Some amazing things to happen B ]"
    3 "Back to Main Menu"
)

my_main_submenu_function() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "This is my submenu" \
                        --menu "Please Choose one of the following options" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${GNOME_SETTINGS_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) menu_option_A ;;
            2) menu_option_B ;;
            3) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
