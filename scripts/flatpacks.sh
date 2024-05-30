#!/bin/bash

# File to store the list of installed Flatpak applications
output_file="flatpak_packages.txt"

check_for_flatpack() {
	# Check if flatpak is enabled
	if ! flatpak --version > /dev/null 2>&1; then
	  echo "Error: flatpak is not enabled on this system"
	  exit 1
	fi
}

# Function to enable Flatpak
enable_flatpak() {
    echo "Enabling Flatpak"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak update -y
    if [ -f flatpak-install.sh ]; then
        source flatpak-install.sh
    else
        log_action "flatpak-install.sh not found"
    fi
    notify "Flatpak has now been enabled"
}


install_flatpacks_from_list() {
	# Read the list of packages from the text file
	PACKAGES=$(cat "$output_file")

	# Install the packages using flatpak
	for PACKAGE in $PACKAGES; do
	  flatpak install -y $PACKAGE
	done
}

store_flatpack_to_list() {
	# Get the list of installed Flatpak applications
	installed_apps=$(flatpak list --app --columns=application | tail -n +1)

	# Create the output file if it doesn't exist
	touch "$output_file"

	# Loop through each installed application
	while IFS= read -r app; do
	    # Check if the application is already in the file
	    if ! grep -q "^$app\$" "$output_file"; then
	        # If not, append it to the file
	        echo "$app" >> "$output_file"
	    fi
	done <<< "$installed_apps"

	echo "Flatpak application list has been updated."
}


# Options for the Core System submenu
FLATPACK_OPTIONS=(
	1 "Enable flatpack"
	2 "install flatpacks from list"
	3 "store flatpack to list"
    4 "Back to Main Menu"
)

# Function to display the Core System submenu
custom_flatpack_packages() {
    while true; do
        CORE_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "Core System" \
                        --menu "Select a core system task:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${FLATPACK_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
			1) enable_flatpak ;;
			2) install_flatpacks_from_list ;;
			3) store_flatpack_to_list ;;
            4) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
