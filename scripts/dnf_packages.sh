#!/bin/bash


# Get the directory of the sourced script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define the output file relative to the script directory
dnf_package_list_file="$SCRIPT_DIR/dnf-packages.txt"


update_dnf_package_list(){
    clear
    log_action "Updating dnf package list based on current system installation ..."
    # Generate the list of packages and store it in a temporary file
    temp_file=$(mktemp)
    dnf repoquery --userinstalled --qf "@%{from_repo} %{name}" | grep -v -E "@(commandline|anaconda|kernel)" | grep -v " kernel" > "$temp_file"

    # Check if the output file exists, if not create it
    if [ ! -f "$dnf_package_list_file" ]; then
        touch "$dnf_package_list_file"
    fi

    # Append only the new lines to the output file
    grep -Fxvf "$dnf_package_list_file" "$temp_file" >> "$dnf_package_list_file"

    # Clean up the temporary file
    rm "$temp_file"

    notify "${dnf_package_list_file} got updated with currently installed packages"
}

install_dnf_packages() {
    clear
    log_action "Starting DNF installation from the list..."
    declare -A repo_packages

    # Loop through each line in the input file to group packages by repo
    log_action "checking if required repository exists"
    while IFS= read -r line; do
        # Extract the repository and package name
        repo=$(echo $line | awk '{print $1}' | sed 's/@//')
        package=$(echo $line | awk '{print $2}')

        # Check if the repository is available
        if ! sudo dnf repolist all | grep -q "^${repo}"; then
            log_action -e "\e[31mERROR: Repository ${repo} not found in the list. Skipping ${package}.\e[0m"
            continue
        fi

        # Group packages by repository
        if [[ -z "${repo_packages[$repo]}" ]]; then
            repo_packages[$repo]=$package
        else
            repo_packages[$repo]="${repo_packages[$repo]} $package"
        fi
    done < "$dnf_package_list_file"
    log_action "grouped packages by repo and proceeding to install..."
    # Install packages for each repository
    for repo in "${!repo_packages[@]}"; do
        packages="${repo_packages[$repo]}"
        notify "Preparing to install packages: $packages from repository: $repo"
        sudo dnf install --enablerepo=$repo -y $packages  &>> $LOG_FILE
    done
    notify "packages from ${dnf_package_list_file} are installed."
}

display_dnf_package_list_file(){
    if [ -f "$dnf_package_list_file" ]; then
        dialog --title "Contents of $dnf_package_list_file" --textbox "$dnf_package_list_file" 40 90
    else
        dialog --title "Info" --msgbox "The file $dnf_package_list_file does not exist." 10 20
    fi
}

manual_edit_dnf_package_list() {
    if [ -f "$dnf_package_list_file" ]; then
        dnf_temp_file=$(mktemp)
        dialog --backtitle "$BACKTITLE" --title "Manual edit $dnf_package_list_file" --editbox "$dnf_package_list_file" 20 60 2> "${dnf_temp_file}"
        
        # Check the exit status of the dialog command
        if [ $? -eq 0 ]; then
            # User clicked OK, copy the temp file back to the original file
            # Create a backup of the original file
            log_action "dnf file edit confirmed. Creating backup copy: ${dnf_package_list_file}_back"
            cp "$dnf_package_list_file" "${dnf_package_list_file}_back"
            cp "${dnf_temp_file}" "$dnf_package_list_file"
        fi
        
        # Clean up the temporary file
        rm "${dnf_temp_file}"
    else
        notify "The file $dnf_package_list_file does not exist."
    fi
}

confirm_dnf_installation(){
    dialog --backtitle "$BACKTITLE" --title "Confirm Installation" --yesno "Do you want to proceed with the installation of packages listed in $dnf_package_list_file?" 20 80
    return $?
}

choose_dnf_package_list_file() {
    log_action "going to choose different dnf package list file"
    while true; do
        local chosen_file=$(dialog --backtitle "$BACKTITLE" --title "Choose DNF Package List File" --fselect "$SCRIPT_DIR/" 40 120 2>&1 >/dev/tty)
        clear
        if [ -z "$chosen_file" ]; then
            notify "No file selected. Using default: $dnf_package_list_file"
            break
        elif [ -f "$chosen_file" ]; then
            dnf_package_list_file="$chosen_file"
            notify "DNF package list file changed to: $dnf_package_list_file"
            break
        else
            notify "$chosen_file is not a file."
        fi
    done
}

create_dnf_list_timer() {
    notify "create dnf list timer not yet implemented"
}



# Options for the Core System submenu
DNF_PACKAGES_OPTIONS=(
    1 "Install DNF packages from list   [ install all packages from dnf-packages       ]"
    2 "Update DNF package list          [ add currently installed packages to the list ]"
    3 "Display content of packages list [ displays contents of dnf-packages file       ]"
    4 "Edit dnf list file               [ Edit contents of dnf-packages list file      ]"
    5 "Choose dnf list file             [ Choose custom dnf package list file          ]"
    6 "Create auto dnf list backup      [ Create sysctrl timer for dnf list backup     ]"
    7 "Back to Main Menu"
)

# Function to display the Core System submenu
custom_dnf_packages() {
    while true; do
        CORE_CHOICE=$(dialog --nocancel \
                        --backtitle "$BACKTITLE" \
                        --title "DNF package installation from list" \
                        --menu "Please choose one of the following options:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${DNF_PACKAGES_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) display_dnf_package_list_file && confirm_dnf_installation && install_dnf_packages ;;
            2) update_dnf_package_list ;;
            3) display_dnf_package_list_file ;;
            4) manual_edit_dnf_package_list ;;
            5) choose_dnf_package_list_file ;;
            6) create_dnf_list_timer ;;
            7) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
