#!/bin/bash

setup_gnome_settings(){
	notify "Turn on recruisive search"
	gsettings set org.gnome.nautilus.preferences recursive-search 'always'

	notify "Changing clock to 24h format"
	gsettings set org.gnome.desktop.interface clock-format '24h'
	gsettings set org.gnome.desktop.interface clock-show-date true
	gsettings set org.gnome.desktop.interface clock-show-seconds false

	notify "Enables battery percentage"
	gsettings set org.gnome.desktop.interface show-battery-percentage true

	notify "Enable window buttons"
	gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

	notify "Fractional Scaling - THIS IS EXPERIMENTAL"
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

	notify  "gnome settings setup complete"
}

install_additional_gnome(){
    notify "installing gnome tweaks and extension manager"
	sudo dnf install -y gnome-tweaks-45.2-1.fc39.noarch gnome-extensions-app-45.3-1.fc39.x86_64
    notify "installation complete"
}



# Options for the Core System submenu
GNOME_SETTINGS_OPTIONS=(
    1 "Setup Gnome settings"
    2 "Install Gnome extension managers"
    3 "Back to Main Menu"
)

# Function to display the Core System submenu
gnome_settings() {
    while true; do
        CORE_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "Core System" \
                        --menu "Select a core system task:" \
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
