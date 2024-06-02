#!/bin/bash

# Individual functions for each setting
setup_recursive_search(){
    log_action "Turn on recursive search"

    local OLD_VALUE=$(gsettings get org.gnome.nautilus.preferences recursive-search)
    log_action "Value before change: ${OLD_VALUE}"

    gsettings set org.gnome.nautilus.preferences recursive-search 'always'  &>> $LOG_FILE

    local NEW_VALUE=$(gsettings get org.gnome.nautilus.preferences recursive-search)
    log_action "Value after change: ${NEW_VALUE}"
}

setup_clock_24h(){
    log_action "Changing clock to 24h format"

    gsettings set org.gnome.desktop.interface clock-format '24h'  &>> $LOG_FILE
    gsettings set org.gnome.desktop.interface clock-show-date true  &>> $LOG_FILE
    gsettings set org.gnome.desktop.interface clock-show-seconds false  &>> $LOG_FILE
}

enable_battery_percentage(){
    log_action "Enables battery percentage"

    local OLD_VALUE=$(gsettings get org.gnome.desktop.interface show-battery-percentage)
    log_action "Value before change: ${OLD_VALUE}"

    gsettings set org.gnome.desktop.interface show-battery-percentage true  &>> $LOG_FILE

    local NEW_VALUE=$(gsettings get org.gnome.desktop.interface show-battery-percentage)
    log_action "Value after change: ${NEW_VALUE}"
}

enable_window_buttons(){
    log_action "Enable window buttons"

    local OLD_VALUE=$(gsettings get org.gnome.desktop.wm.preferences button-layout)
    log_action "Value before change: ${OLD_VALUE}"

    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"  &>> $LOG_FILE

    local NEW_VALUE=$(gsettings get org.gnome.desktop.wm.preferences button-layout)
    log_action "Value after change: ${NEW_VALUE}"
}

setup_fractional_scaling(){
    log_action "Fractional Scaling - THIS IS EXPERIMENTAL"

    local OLD_VALUE=$(gsettings get org.gnome.mutter experimental-features )
    log_action "Value before change: ${OLD_VALUE}"

    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"  &>> $LOG_FILE

    local NEW_VALUE=$(gsettings get org.gnome.mutter experimental-features )
    log_action "Value after change: ${NEW_VALUE}"
}

unbind_super_key(){
    log_action "Unbind Super key, preventing opening the GNOME Shell overview mode"

    local OLD_VALUE=$(gsettings get org.gnome.mutter overlay-key)
    log_action "Value before change: ${OLD_VALUE}"

    gsettings set org.gnome.mutter overlay-key ''  &>> $LOG_FILE

    local NEW_VALUE=$(gsettings get org.gnome.mutter overlay-key)
    log_action "Value after change: ${NEW_VALUE}"
}

program_not_responding() {
    log_action "Change program not responding time"

    # Use dialog to ask for the time in seconds
    TIME_IN_SEC=$(dialog --stdout --inputbox "Enter time in seconds:" 8 40)

    # Check if the user provided a value
    if [ -n "$TIME_IN_SEC" ]; then
        # Convert seconds to milliseconds
        TIME_IN_MS=$((TIME_IN_SEC * 1000))

        local OLD_VALUE=$(gsettings get org.gnome.mutter check-alive-timeout)
        log_action "Value before change: ${OLD_VALUE} (in milliseconds)"

        gsettings set org.gnome.mutter check-alive-timeout $TIME_IN_MS &>> $LOG_FILE

        if [ $? -eq 0 ]; then
            local NEW_VALUE=$(gsettings get org.gnome.mutter check-alive-timeout)
            log_action "Successfully set check-alive-timeout to ${TIME_IN_MS} ms"
            log_action "Value after change: ${NEW_VALUE} (in milliseconds)"
        else
            notify "Failed to set check-alive-timeout"
        fi
    else
        notify "No time provided, aborting"
    fi
}


apply_selected_gnome_settings() {
    local selections=("$@")
    for selection in "${selections[@]}"; do
        case $selection in
            1) setup_recursive_search ;;
            2) setup_clock_24h ;;
            3) enable_battery_percentage ;;
            4) enable_window_buttons ;;
            5) setup_fractional_scaling ;;
            6) program_not_responding ;;
            *) log_action "Invalid selection: $selection" ;;
        esac
    done
    notify "Selected Gnome settings applied!"
}

# Function to display the Gnome settings submenu
gnome_settings() {
    while true; do
        local selections
        selections=$(dialog --clear \
                    --ok-label "Apply selected" --cancel-label "Back" \
                    --backtitle "$BACKTITLE" \
                    --title "GNOME settings" \
                    --checklist "Select settings to apply:" \
                    20 80 10 \
                    1 "Turn on recursive search" OFF \
                    2 "Change clock to 24h format" OFF \
                    3 "Enable battery percentage" OFF \
                    4 "Enable window buttons" OFF \
                    5 "Enable fractional scaling" OFF \
                    6 "Set 'not responding' wait time" OFF \
                    3>&1 1>&2 2>&3)

        exit_status=$?

        if [ $exit_status -ne 0 ]; then
            break
        fi

        selections=($(echo $selections | tr -d '"'))
        log_action "Selected options: ${selections[*]}"
        apply_selected_gnome_settings "${selections[@]}"
    done
}

