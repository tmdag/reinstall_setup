#!/bin/bash

install_1password() {
    clear
    log_action "Installing 1Password"

    # Define the repository configuration
    REPO_FILE="/etc/yum.repos.d/1password.repo"
    REPO_CONTENT="[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
#repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc"

    # Check if the repository file already exists
    if [ -f "$REPO_FILE" ]; then
        log_action "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        notify "Repository file $REPO_FILE created."
    fi

    # Use the function to install 1Password if needed
    sudo dnf install -y 1password &>> $LOG_FILE
    log_action "installation of 1password complete"
}


install_sublime_text() {
    clear
    log_action "Installing Sublime Text"

    # Define the repository configuration
    REPO_FILE="/etc/yum.repos.d/sublime-text.repo"
    REPO_CONTENT="[sublime-text]
name=Sublime Text - x86_64 - Dev
baseurl=https://download.sublimetext.com/rpm/dev/x86_64
enabled=1
gpgcheck=1
gpgkey=https://download.sublimetext.com/sublimehq-rpm-pub.gpg"

    # Check if the repository file already exists
    if [ -f "$REPO_FILE" ]; then
        log_action "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        notify "Repository file $REPO_FILE created."
    fi

    # Install Sublime Text
    sudo dnf install -y  sublime-text  &>> $LOG_FILE
    log_action "installation of Sublime Text complete"
}

install_vscode() {
    clear
    log_action "Installing Visual Studio Code"

    # Define the repository configuration
    REPO_FILE="/etc/yum.repos.d/vscode.repo"
    REPO_CONTENT="[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc"

    # Check if the repository file already exists
    if [ -f "$REPO_FILE" ]; then
        log_action "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        notify "Repository file $REPO_FILE created."
    fi

    # Install Visual Studio Code
    sudo dnf install -y  code &>> $LOG_FILE
    log_action "Installatio of VScode complete"
}

install_google_chrome() {
    clear
    log_action "Installing Google Chrome"

    # Define the repository configuration
    REPO_FILE="/etc/yum.repos.d/google-chrome.repo"
    REPO_CONTENT="[google-chrome]
name=Google Chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub"

    # Check if the repository file already exists
    if [ -f "$REPO_FILE" ]; then
        log_action "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        notify "Repository file $REPO_FILE created."
    fi

    # Install Google Chrome
    sudo dnf install -y google-chrome-stable &>> $LOG_FILE
    log_action "Installation of Google Chrome complete!"
}

install_wireguard() {
    clear
    log_action "Installing Wireguard"
    sudo dnf install -y wireguard &>> $LOG_FILE
    log_action "Installation fo wireguard complete"
}

install_audacity() {
    clear
    log_action "Installing Audacity"
    sudo dnf install -y audacity &>> $LOG_FILE
    log_action "Installation fo Audacity complete"
}

install_vorta_borg_backup() {
    clear
	log_action "Installing Vorta and Borg Backup"
	sudo dnf install -y vorta.noarch borgbackup &>> $LOG_FILE
    log_action "Installation of Vorta and Borg Backup complete"
}

install_system_tools() {
    clear
	log_action "Installing system tools (htop, nvtop, tree, gparted, conda)"
	sudo dnf install -y btop nvtop htop tree gparted conda &>> $LOG_FILE
    log_action "Installation of system tools complete"
}


install_selected_packages() {
    local selections=("$@")
    for selection in "${selections[@]}"; do
        case $selection in
            1) install_1password ;;
            2) install_sublime_text ;;
            3) install_vscode ;;
            4) install_google_chrome ;;
            5) install_wireguard ;;
            6) install_audacity ;;
            7) install_vorta_borg_backup ;;
            8) install_system_tools ;;
        esac
    done
    notify "Selected software installation complete!"
}


# Function to display the Core System submenu
install_additional_software() {
    while true; do
        local selections
        selections=$(dialog --clear \
                    --ok-label "install selected" --cancel-label "Back" \
                    --backtitle "$BACKTITLE" \
                    --title "Additional software installation" \
                    --checklist "Select Software to be installed" \
                    20 80 10 \
                    1 "1Password                " on \
                    2 "Sublime Text             " on \
                    3 "Visual Studio Code       " on \
                    4 "Google Chrome            " on \
                    5 "Wireguard                " on \
                    6 "Audacity                 " on \
                    7 "Vorta Borg Backup        [UI for Borg Backup system]" on \
                    8 "System Tools             [btop, nvtop, htop, tree, gparted, conda]" on \
                    3>&1 1>&2 2>&3 3>&-)

        exit_status=$?

        if [ $exit_status -ne 0 ]; then
            break
        fi

        selections=($(echo $selections | tr -d '"'))
        log_action "Selected options: ${selections[*]}"
        install_selected_packages "${selections[@]}"
    done
}
