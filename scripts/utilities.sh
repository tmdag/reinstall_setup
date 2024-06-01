#!/bin/bash


display_log_file(){
    log_action "displaying log file ..."
    if [ -f "$LOG_FILE" ]; then
        dialog --title "Reinstall app LOG:" --textbox "$LOG_FILE" 40 160
    else
        notify "The file $LOG_FILE does not exist."
    fi
}

clear_log_file(){
    log_action "clearing log file ..."
    if [ -f "$LOG_FILE" ]; then
        echo "" > $LOG_FILE
        notify "log file has been cleared"
    else
        notify "The file $LOG_FILE does not exist."
    fi
}

open_mc(){
    log_action "opening midnight commander ..."
	clear
	mc
}

# Options for the Core System submenu
UTILITY_OPTIONS=(
    1 "Display Log File                  [ Displays contents of the log file           ]"
    2 "Clear Log File                    [ Clears contents of the log file             ]"
    3 "Open Midnight Commander           [ Opens Midnight Commander                    ]"
    4 "Back to Main Menu"
)

# Function to display the Core System submenu
utilitiy_tools() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "Utilities" \
                        --menu "Please select utility task to perform:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${UTILITY_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) display_log_file ;;
            2) clear_log_file ;;
            3) open_mc ;;
            4) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
