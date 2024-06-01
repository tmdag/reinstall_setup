#!/bin/bash

# Individual functions for each setting
setup_recursive_search(){
    log_action "Turn on recursive search"
    gsettings set org.gnome.nautilus.preferences recursive-search 'always'
}

setup_clock_24h(){
    log_action "Changing clock to 24h format"
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-show-seconds false
}

enable_battery_percentage(){
    log_action "Enables battery percentage"
    gsettings set org.gnome.desktop.interface show-battery-percentage true
}

enable_window_buttons(){
    log_action "Enable window buttons"
    gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
}

setup_fractional_scaling(){
    log_action "Fractional Scaling - THIS IS EXPERIMENTAL"
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
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
                    1 "Turn on recursive search" ON \
                    2 "Change clock to 24h format" ON \
                    3 "Enable battery percentage" ON \
                    4 "Enable window buttons" ON \
                    5 "Enable fractional scaling" ON \
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

