#!/bin/bash


# Get the directory of the sourced script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define the output file relative to the script directory
flatpak_list_file="$SCRIPT_DIR/flatpak-packages.txt"


check_for_flatpack() {
    clear
    log_action "checking for flatpack installation"
    # Check if flatpak is enabled
    if ! flatpak --version > /dev/null 2>&1; then
      notify "Error: flatpak is not enabled on this system"
      exit 1
    fi
}

enable_flatpak() {
    clear
    log_action "Enabling Flatpak repository"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak update -y
    notify "Flatpak has now been enabled"
}

install_flatpacks_from_list() {
    clear
    log_action "lets install flatpacks from the list"
    check_for_flatpack
    # Read the list of packages from the text file
    PACKAGES=$(cat "$flatpak_list_file")

    # Install the packages using flatpak
    for PACKAGE in $PACKAGES; do
      flatpak install -y $PACKAGE
    done
    notify "Flatpak packages has been installed"
}

store_flatpack_to_list() {
    clear
    # Get the list of installed Flatpak applications
    installed_apps=$(flatpak list --app --columns=application | tail -n +1)

    # Create the output file if it doesn't exist
    touch "$flatpak_list_file"

    # Loop through each installed application
    while IFS= read -r app; do
        # Check if the application is already in the file
        if ! grep -q "^$app\$" "$flatpak_list_file"; then
            # If not, append it to the file
            echo "$app" >> "$flatpak_list_file"
        fi
    done <<< "$installed_apps"

    notify "Flatpak application list has been updated."
}

display_flatpak_list_file(){
    if [ -f "$flatpak_list_file" ]; then
        dialog --title "Contents of $flatpak_list_file" --textbox "$flatpak_list_file" 40 80
    else
        dialog --title "Info" --msgbox "The file $flatpak_list_file does not exist." 60 20
    fi
}

manual_edit_flatpak_package_list() {
    if [ -f "$flatpak_list_file" ]; then
        dnf_temp_file=$(mktemp)
        dialog --backtitle "$BACKTITLE" --title "Manual edit $flatpak_list_file" --editbox "$flatpak_list_file" 20 60 2> "${dnf_temp_file}"
        
        # Check the exit status of the dialog command
        if [ $? -eq 0 ]; then
            # User clicked OK, copy the temp file back to the original file
            # Create a backup of the original file
            log_action "create a backup copy ${flatpak_list_file}_back"
            cp "$flatpak_list_file" "${flatpak_list_file}_back"
            cp "${dnf_temp_file}" "$flatpak_list_file"
        fi
        
        # Clean up the temporary file
        rm "${dnf_temp_file}"
    else
        notify "The file $flatpak_list_file does not exist."
    fi
}

confirm_flatpak_installation(){
    dialog --backtitle "$BACKTITLE" --title "Confirm Installation" --yesno "Do you want to proceed with the installation of packages listed in $flatpak_list_file?" 20 80
    return $?
}

choose_flatpak_list_file() {
    log_action "going to choose different flatpak package list file"
    while true; do
        local chosen_flatpak_file=$(dialog --backtitle "$BACKTITLE" --title "Choose Flatpak Package List File" --fselect "$SCRIPT_DIR/" 40 120 2>&1 >/dev/tty)
        clear
        if [ -z "$chosen_flatpak_file" ]; then
            notify "No file selected. Using default: $flatpak_list_file"
            break
        elif [ -f "$chosen_flatpak_file" ]; then
            flatpak_list_file="$chosen_flatpak_file"
            notify "Flatpak package list file changed to: $flatpak_list_file"
            break
        else
            notify "$chosen_flatpak_file is not a file."
        fi
    done
}


# Options for the Core System submenu
FLATPACK_OPTIONS=(
    1 "Enable flatpack                   [ Enable Flatpack on the system               ]"
    2 "Display content of packages list  [ Display contents of flatpak-packages.txt    ]"
    3 "Install flatpacks from list       [ Install apps from flatpak-packages.txt list ]"
    4 "Store installed flatpacks to list [ Auto update list from currently installed   ]"
    5 "Edit flatpack list file           [ Edit contents of flatpak-packages.txt       ]"
    6 "Choose flatpack list file         [ Choose custom flatpack package list file    ]"
    7 "Back to Main Menu"
)

# Function to display the Core System submenu
custom_flatpack_packages() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "Flatpak installation" \
                        --menu "Please select one of following options:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${FLATPACK_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) enable_flatpak ;;
            2) display_flatpak_list_file ;;
            3) display_flatpak_list_file && confirm_flatpak_installation $$ install_flatpacks_from_list ;;
            4) store_flatpack_to_list ;;
            5) manual_edit_flatpak_package_list ;;
            6) choose_flatpak_list_file ;;
            7) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
