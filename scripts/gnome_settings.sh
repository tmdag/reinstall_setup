#!/bin/bash

setup_gnome_settings(){
    clear
	log_action "Turn on recruisive search"
	gsettings set org.gnome.nautilus.preferences recursive-search 'always'

	log_action "Changing clock to 24h format"
	gsettings set org.gnome.desktop.interface clock-format '24h'
	gsettings set org.gnome.desktop.interface clock-show-date true
	gsettings set org.gnome.desktop.interface clock-show-seconds false

	log_action "Enables battery percentage"
	gsettings set org.gnome.desktop.interface show-battery-percentage true

	log_action "Enable window buttons"
	gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

	log_action "Fractional Scaling - THIS IS EXPERIMENTAL"
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

	notify  "gnome settings setup complete"
}

install_additional_gnome(){
    clear
    log_action "installing gnome tweaks and extension manager"
	sudo dnf install -y gnome-tweaks gnome-extensions-app &>> $LOG_FILE
    notify "installation of Gnome extensions and tweaks complete"
}


# Options for the Core System submenu
GNOME_SETTINGS_OPTIONS=(
    1 "Setup Gnome settings              [recruisive search, 24h clock, battery %, window buttons, DPI scalling]"
    2 "Install Gnome extension managers  [gnome-tweaks, gnome-extension manager]"
    3 "Back to Main Menu"
)

# Function to display the Core System submenu
gnome_settings() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "Gnome settings" \
                        --menu "Select task to perform:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${GNOME_SETTINGS_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) setup_gnome_settings ;;
            2) install_additional_gnome ;;
            3) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
