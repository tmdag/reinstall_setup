#!/bin/bash

# Get the directory of the sourced script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define the output file relative to the script directory
gnome_extensions_list_file="$SCRIPT_DIR/../gnome-extensions.txt"

install_additional_gnome(){
    clear
    log_action "installing gnome tweaks and extension manager"
    sudo dnf install -y gnome-tweaks gnome-extensions-app &>> $LOG_FILE
    notify "installation of Gnome extensions and tweaks complete"
}


# Function to update the list of installed GNOME Shell extensions
update_extension_list() {
    clear
    log_action "Updating GNOME Shell extensions list based on current system installation ..."

    # Generate the list of extensions and store it in a temporary file
    temp_file=$(mktemp)

    if ! gnome-extensions list > "$temp_file"; then
        notify "Failed to connect to GNOME Shell (make sure this is NOT running as root)\n\n\
        USER: $USER \n\
        DBUS_SESSION_BUS_ADDRESS: $DBUS_SESSION_BUS_ADDRESS \n\
        XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR \n\
        DISPLAY: $DISPLAY"
        return 1
    fi

    # Check if the output file exists, if not create it
    if [ ! -f "$gnome_extensions_list_file" ]; then
        touch "$gnome_extensions_list_file"
    fi

    # Append only the new lines to the output file
    grep -Fxvf "$gnome_extensions_list_file" "$temp_file" >> "$gnome_extensions_list_file"

    # Clean up the temporary file
    rm "$temp_file"

    notify "${gnome_extensions_list_file} got updated with currently installed GNOME Shell extensions"
}

# Function to install GNOME Shell extensions
install_gnome_extension() {
    # helper function
    local extension_id="$1"

    gdbus call --session \
             --dest org.gnome.Shell.Extensions \
             --object-path /org/gnome/Shell/Extensions \
             --method org.gnome.Shell.Extensions.InstallRemoteExtension \
             "$extension_id"

    if [[ $? -eq 0 ]]; then
    log_action "Extension '$extension_id' installed successfully."
    else
    log_action "Failed to install extension '$extension_id'."
    fi
}

# Function to install GNOME Shell extensions from a list
install_gnome_extensions_from_list() {
    clear
    log_action "Going to install extensions from the list"

    if [[ ! -f "$gnome_extensions_list_file" ]]; then
    notify "List file '$gnome_extensions_list_file' not found."
    return 1
    fi

    while IFS= read -r extension_id; do
    install_gnome_extension "$extension_id"
    done < "$gnome_extensions_list_file"
    notify "Extensions from the list installed successfully"
}

# Function to display GNOME extensions list file
display_gnome_extensions_list_file(){
    log_action "Displaying GNOME extensions list file"
    if [ -f "$gnome_extensions_list_file" ]; then
        dialog --title "Contents of $gnome_extensions_list_file" --textbox "$gnome_extensions_list_file" 40 90
    else
        notify "The file $gnome_extensions_list_file does not exist." 
    fi
}

# Function to manually edit GNOME extensions list
manual_edit_gnome_extensions_list() {
    log_action "Manually editing GNOME extensions list"
    if [ -f "$gnome_extensions_list_file" ]; then
        gnome_temp_file=$(mktemp)
        dialog --backtitle "$BACKTITLE" --title "Manual edit $gnome_extensions_list_file" --editbox "$gnome_extensions_list_file" 20 60 2> "${gnome_temp_file}"
        
        if [ $? -eq 0 ]; then
            log_action "GNOME extensions list edit confirmed. Creating backup copy: ${gnome_extensions_list_file}_back"
            cp "$gnome_extensions_list_file" "${gnome_extensions_list_file}_back"
            cp "${gnome_temp_file}" "$gnome_extensions_list_file"
        fi
        
        rm "${gnome_temp_file}"
    else
        notify "The file $gnome_extensions_list_file does not exist."
    fi
}

# Function to confirm GNOME extension installation
confirm_gnome_installation(){
    dialog --backtitle "$BACKTITLE" --title "Confirm Installation" --yesno "Do you want to proceed with the installation of extensions listed in $gnome_extensions_list_file?" 20 80
    return $?
}

# Function to choose GNOME extensions list file
choose_gnome_extensions_list_file() {
    log_action "Choosing different GNOME extensions list file"
    while true; do
        local chosen_file=$(dialog --backtitle "$BACKTITLE" --title "Choose GNOME Extensions List File" --fselect "$SCRIPT_DIR/" 40 120 2>&1 >/dev/tty)
        clear
        if [ -z "$chosen_file" ]; then
            notify "No file selected. Using default: $gnome_extensions_list_file"
            break
        elif [ -f "$chosen_file" ]; then
            gnome_extensions_list_file="$chosen_file"
            notify "GNOME extensions list file changed to: $gnome_extensions_list_file"
            break
        else
            notify "$chosen_file is not a file."
        fi
    done
}

################################################################################################
# Menu options
GNOME_SETTINGS_OPTIONS=(
    1 "Install extension managers          [ gnome-tweaks, gnome-extension manager    ]"
    2 "Install extensions from list        [ install all extensions from list         ]"
    3 "Update extensions list              [ add installed extensions to the list     ]"
    4 "Display content of extensions list  [ display contents extensions list file    ]"
    5 "Edit extensions list file           [ edit  extensions list file               ]"
    6 "Choose extensions list file         [ choose custom extensions list file       ]"
    7 "Back to Main Menu"
)

# Function to display the GNOME settings menu
gnome_extensions_menu() {
    while true; do
        local choice=$(dialog --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "GNOME Extensions Management" \
                        --menu "Please choose one of the following options:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${GNOME_SETTINGS_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $choice in
            1) install_additional_gnome ;;
            2) display_gnome_extensions_list_file && confirm_gnome_installation && install_gnome_extensions_from_list ;;
            3) update_extension_list ;;
            4) display_gnome_extensions_list_file ;;
            5) manual_edit_gnome_extensions_list ;;
            6) choose_gnome_extensions_list_file ;;
            7) break ;;
            *) log_action "Invalid option selected: $choice";;
        esac
    done
}

