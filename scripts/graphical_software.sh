#!/bin/bash

install_all_gfx() {
    notify "Installing all graphics applications"
    install_image_converters
    install_AudioVideo_apps
    install_obs_studio
    install_darktable
    install_blender
    install_usd_opencv
    install_nonwayland_apps

    notify "All graphics applications installation complete"
}

install_image_converters() {
    notify "Installing ImageMagick, GraphicsMagick, gifsicle"
    sudo dnf install ImageMagick.x86_64 GraphicsMagick.x86_64 gifsicle.x86_64 -y

    notify "Image converters and apps complete"
}

install_AudioVideo_apps() {
    notify "Installing Gimp"
    sudo dnf install gimp.x86_64 -y

    notify "Installation of audio/video apps complete"
}

install_obs_studio() {
    notify "Installing OBS Studio"
    sudo dnf install obs-studio.x86_64 -y

    notify "OBS Studio installation complete"
}

install_darktable() {
    notify "Installing Darktable"
    sudo dnf install darktable.x86_64 -y

    notify "Darktable installation complete"
}

install_blender() {
    notify "Installing Blender"
    sudo dnf install blender.x86_64 -y

    notify "Blender installation complete"
}

install_usd_opencv() {
	sudo dnf instlal -y usd.x86_64 usd-devel.x86_64 opencv.x86_64
}

install_nonwayland_apps() {
	if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
		notify "installing peek and flameshot"
		sudo dnf install -y peek.x86_64 flameshot.x86_64
		notify "Installation of audio/video apps complete"
	else
	    notify "Won't install - those apps won't run on wayland"
	fi
}

install_ffmpeg() {
    notify "Installing RPMFusion ffmpeg"
    # Switch to full ffmpeg
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing

    # Install additional codec
    sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
    sudo dnf update @sound-and-video

    # Hardware Accelerated Codec
    sudo dnf install intel-media-driver

    #Hardware codecs with NVIDIA
    sudo dnf install libva-nvidia-driver
    notify "All done"
}



# Options for the Core System submenu
GFX_SOFTWARE_OPTIONS=(
    1 "Install all gfx"
    2 "Install image converters"
    3 "Install AudioVideo apps"
    4 "Install obs studio"
    5 "Install darktable"
    6 "Install blender"
    7 "Install usd opencv"
    8 "Install non-Wayland apps"
    9 "Install ffmpeg"
    10 "Back to Main Menu"
)

# Function to display the Core System submenu
install_gfx_software() {
    while true; do
        CORE_CHOICE=$(dialog --clear \
                        --backtitle "$BACKTITLE" \
                        --title "Core System" \
                        --menu "Select a core system task:" \
                        $HEIGHT $WIDTH $CHOICE_HEIGHT \
                        "${GFX_SOFTWARE_OPTIONS[@]}" \
                        2>&1 >/dev/tty)

        clear
        case $CORE_CHOICE in
            1) install_all_gfx ;;
            2) install_image_converters ;;
            3) install_AudioVideo_apps ;;
            4) install_obs_studio ;;
            5) install_darktable ;;
            6) install_blender ;;
            7) install_usd_opencv ;;
            8) install_nonwayland_apps ;;
            9) install_ffmpeg ;;
            10) break ;;
            *) log_action "Invalid option selected: $CORE_CHOICE";;
        esac
    done
}

