#!/bin/bash

# Define the output file
dnf_package_list="dnf-packages.txt"


update_dnf_package_list(){
    # Generate the list of packages and store it in a temporary file
    temp_file=$(mktemp)
    dnf repoquery --userinstalled --qf "@%{from_repo} %{name}" | grep -v -E "@(commandline|anaconda|kernel)" | grep -v " kernel" > "$temp_file"

    # Check if the output file exists, if not create it
    if [ ! -f "$dnf_package_list" ]; then
        touch "$dnf_package_list"
    fi

    # Append only the new lines to the output file
    grep -Fxvf "$dnf_package_list" "$temp_file" >> "$dnf_package_list"

    # Clean up the temporary file
    rm "$temp_file"
}


install_dnf_packages(){
    declare -A repo_packages

    # Loop through each line in the input file to group packages by repo
    while IFS= read -r line; do
        # Extract the repository and package name
        repo=$(echo $line | awk '{print $1}' | sed 's/@//')
        package=$(echo $line | awk '{print $2}')

        # Check if the repository is available
        if ! sudo dnf repolist all | grep -q "^${repo}"; then
            echo -e "\e[31mERROR: Repository ${repo} not found in the list. Skipping ${package}.\e[0m"
            continue
        fi

        # Group packages by repository
        if [[ -z "${repo_packages[$repo]}" ]]; then
            repo_packages[$repo]=$package
        else
            repo_packages[$repo]="${repo_packages[$repo]} $package"
        fi
    done < "$dnf_package_list"

    # Install packages for each repository
    for repo in "${!repo_packages[@]}"; do
        packages="${repo_packages[$repo]}"
        echo "Preparing to install packages: $packages from repository: $repo"

        # sudo dnf install --enablerepo=$repo -y $packages

    done
}


# Options for the Core System submenu
DNF_PACKAGES_OPTIONS=(
    1 "Update DNF package list"
    2 "Install DNF packages from list"
    3 "Back to Main Menu"
)

# Function to display the Core System submenu
custom_dnf_packages() {
    while true; do
        CORE_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "Core System" \
                        --menu "Select a core system task:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${DNF_PACKAGES_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) update_dnf_package_list ;;
            2) install_dnf_packages ;;
            3) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
