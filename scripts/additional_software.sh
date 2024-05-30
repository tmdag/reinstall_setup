#!/bin/bash

install_all_additional_packages() {
    echo "Installing ALL Software"
    install_1password
    install_sublime_text
    install_vscode
    install_google_chrome
    install_audacity
    install_vorta_borg_backup
    install_system_tools
    notify "All additional software installation complete!"
}



# Function to check if a package is installed and install it if not
install_package_if_needed() {
    local package=$1
    echo "Checking if $package is installed..."

    if rpm -q $package &> /dev/null; then
        echo "$package is already installed."
    else
        echo "$package is not installed. Installing it now..."
        sudo dnf install -y $package
        if [ $? -eq 0 ]; then
            echo "$package installation complete"
            notify "$package installation complete"
        else
            echo "Failed to install $package"
            notify "Failed to install $package"
            exit 1
        fi
    fi
}

install_1password() {
    echo "Installing 1Password"

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
        echo "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        echo "Repository file $REPO_FILE created."
    fi

    # Use the function to install 1Password if needed
    install_package_if_needed "1password"
}


install_sublime_text() {
    echo "Installing Sublime Text"

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
        echo "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        echo "Repository file $REPO_FILE created."
    fi

    # Install Sublime Text
    install_package_if_needed sublime-text 
}

install_vscode() {
    echo "Installing Visual Studio Code"

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
        echo "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        echo "Repository file $REPO_FILE created."
    fi

    # Install Visual Studio Code
    install_package_if_needed code
}

install_google_chrome() {
    echo "Installing Google Chrome"

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
        echo "Repository file $REPO_FILE already exists."
    else
        # Create the repository file
        echo "$REPO_CONTENT" | sudo tee "$REPO_FILE" > /dev/null
        echo "Repository file $REPO_FILE created."
    fi

    # Install Google Chrome
    install_package_if_needed google-chrome-stable
}


install_audacity() {
    echo "Installing Gimp, obs-studio"
    install_package_if_needed audacity.x86_64
}

install_vorta_borg_backup() {
	echo "Installing Vorta, Borg Backup system ui"
	install_package_if_needed vorta.noarch
}

install_system_tools() {
	echo "Installing system tools"
	echo "htop, tree, gparted, conda"
	sudo dnf install -y htop.x86_64 tree.x86_64 gparted.x86_64 conda.noarch
    notify "Installation of system tools complete"
}



# Options for the Core System submenu
ADDITIONAL_SOFT_OPTIONS=(
    1 "Install all additional packages"
    2 "Install 1password"
    3 "Install sublime text"
    4 "Install vscode"
    5 "Install google chrome"
    6 "Install audacity"
    7 "Install vorta borg backup"
    8 "Install system tools"
    9 "Back to Main Menu"
)

# Function to display the Core System submenu
install_additional_software() {
    while true; do
        CORE_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "Core System" \
                        --menu "Select a core system task:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${ADDITIONAL_SOFT_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) install_all_additional_packages ;;
            2) install_1password ;;
            3) install_sublime_text ;;
            4) install_vscode ;;
            5) install_google_chrome ;;
            6) install_audacity ;;
            7) install_vorta_borg_backup ;;
            8) install_system_tools ;;
            9) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
