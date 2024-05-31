#!/bin/bash


ask_for_kernel(){
    dialog --backtitle "$BACKTITLE" --title "Confirm Installation" --yesno "Please make sure you are on the latest kernel" 10 80
    return $?
}

install_nvidia() {
    clear
	log_action "Installing RPMFusion nvidia drivers"
	sudo dnf -y install akmod-nvidia # rhel/centos users can use kmod-nvidia instead
	sudo dnf -y install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
    notify "All done, please reboot the system"
}

# CUDA from RPM fusion
install_cuda() {
    clear
    log_action "Installing RPMFusion CUDA"
	sudo dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
	sudo dnf module disable nvidia-driver
	sudo dnf -y install cuda
    notify "Installing RPMFusion CUDA complete"
}

speed_up_dnf() {
    log_action "Speeding Up DNF"
    if ! grep -q '^max_parallel_downloads' /etc/dnf/dnf.conf; then
        echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
        notify "Your DNF config has now been amended"
    else
        notify "DNF config already contains max_parallel_downloads option"
    fi
}


# Options for the Core System submenu
CORE_SYSTEM_OPTIONS=(
    1 "Install RPM Nvidia drivers   "
    2 "Install RPM CUDA drivers     "
    3 "Speed Up DNF                 [Sets up DNF paraller downloads to 10] "
    4 "Back to Main Menu"
)

# Function to display the Core System submenu
core_system_menu() {
    while true; do
        CORE_CHOICE=$(dialog --clear --nocancel\
                        --backtitle "$BACKTITLE" \
                        --title "Please Make a Selection" \
                        --menu "Please Choose one of the following options:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${CORE_SYSTEM_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) ask_for_kernel && install_nvidia ;;
            2) install_cuda ;;
            3) speed_up_dnf ;;
            4) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}
