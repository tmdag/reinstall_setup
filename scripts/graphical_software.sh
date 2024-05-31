#!/bin/bash


install_image_converters() {
    clear
    log_action "Installing ImageMagick, GraphicsMagick, gifsicle"
    sudo dnf install ImageMagick.x86_64 GraphicsMagick.x86_64 gifsicle.x86_64 -y &>> $LOG_FILE
    log_action "Image converters and apps complete"
}

install_Gimp() {
    clear
    log_action "Installing Gimp"
    sudo dnf install gimp.x86_64 -y &>> $LOG_FILE
    log_action "Installation of Gimp complete"
}

install_obs_studio() {
    clear
    log_action "Installing OBS Studio"
    sudo dnf install obs-studio.x86_64 -y &>> $LOG_FILE
    log_action "OBS Studio installation complete"
}

install_darktable() {
    clear
    log_action "Installing Darktable"
    sudo dnf install darktable.x86_64 -y &>> $LOG_FILE
    log_action "Darktable installation complete"
}

install_blender() {
    clear
    log_action "Installing Blender"
    sudo dnf install blender.x86_64 -y &>> $LOG_FILE
    log_action "Blender installation complete"
}

install_usd_opencv() {
    clear
	sudo dnf instlal -y usd.x86_64 usd-devel.x86_64 opencv.x86_64 &>> $LOG_FILE
    log_action "Installation of usd and opencv complete"
}

install_xnview(){
    notify "Downloading and installing XnView"

    URL="https://download.xnview.com/XnViewMP-linux-x64.tgz"
    TARGET_DIR="/opt/"
    TMP_DIR="/tmp/xnview"
    # Create temporary directory
    mkdir -p $TMP_DIR
    # Download the tarball
    wget -O $TMP_DIR/XnViewMP-linux-x64.tgz $URL &>> $LOG_FILE
    # Extract the tarball
    tar -xzf $TMP_DIR/XnViewMP-linux-x64.tgz -C $TMP_DIR 
    sudo cp -r $TMP_DIR/* $TARGET_DIR
    rm -rf $TMP_DIR

    # Create .desktop file
    sudo bash -c "cat > $DESKTOP_FILE << EOL
    [Desktop Entry]
    Encoding=UTF-8
    Terminal=false
    Exec=$TARGET_DIR/xnview.sh
    Icon=$TARGET_DIR/xnview.png
    Type=Application
    Categories=Graphics;Viewer;RasterGraphics;2DGraphics;Photography;Qt;
    StartupNotify=true
    Name=XnView MP
    MimeType=image/bmp;image/jpeg;image/png;image/tiff;image/gif;image/g3fax;image/pcx;image/svg+xml;image/x-compressed-xcf;image/x-fits;image/x-icon;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-psd;image/x-sgi;image/x-tga;image/x-wmf;image/x-xbitmap;image/x-xcf;image/x-xpixmap;image/x-xwindowdump;
    X-Desktop-File-Install-Version=0.26
    StartupWMClass=XnView
    GenericName=Image Viewer
    Comment=View and organize your images
    Keywords=XnView;Image;Viewer;
    X-Flatpak-Tags=proprietary;
    X-Flatpak=com.xnview.XnViewMP
    EOL"

    # Update the desktop database
    sudo update-desktop-database

    # Print success message
    notify "XnViewMP has been successfully installed to $TARGET_DIR and a desktop entry has been created."
}

install_nonwayland_apps() {
    clear
	if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
		log_action "installing peek and flameshot"
		sudo dnf install -y peek.x86_64 flameshot.x86_64
		notify "Installation of audio/video apps complete"
	else
	    notify "Won't install - those apps won't run on wayland"
	fi
}

install_ffmpeg() {
    clear
    log_action "Installing RPMFusion ffmpeg"
    # Switch to full ffmpeg
    sudo dnf swap ffmpeg-free ffmpeg --allowerasing &>> $LOG_FILE

    # Install additional codec
    sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin &>> $LOG_FILE
    sudo dnf update @sound-and-video &>> $LOG_FILE

    # Hardware Accelerated Codec
    sudo dnf install intel-media-driver &>> $LOG_FILE

    #Hardware codecs with NVIDIA
    sudo dnf install libva-nvidia-driver &>> $LOG_FILE
    notify "All done"
}

install_selected_gfx_software() {
    local selections=("$@")
    for selection in "${selections[@]}"; do
        case $selection in
            1) install_image_converters ;;
            2) install_Gimp ;;
            3) install_obs_studio ;;
            4) install_darktable ;;
            5) install_blender ;;
            6) install_usd_opencv ;;
            7) install_xnview ;;
            8) install_nonwayland_apps ;;
            9) install_ffmpeg ;;
            *) log_action "Invalid selection: $selection" ;;
        esac
    done
    notify "Selected software installation complete!"
}

# Function to display the Core System submenu
install_gfx_software() {
    while true; do
        local selections
        selections=$(dialog --clear \
                    --ok-label "install selected" --cancel-label "Back" \
                    --backtitle "$BACKTITLE" \
                    --title "Graphical software installation" \
                    --checklist "Select software to be installed:" \
                    20 80 10 \
                    1 "image converters     [ ImageMagick, GraphicsMagick, gifsicle     ]" ON \
                    2 "Gimp                 [ drawing software                          ]" ON \
                    3 "obs studio           [ streamign and recording                   ]" ON \
                    4 "darktable            [ Photo editing software                    ]" ON \
                    5 "blender              [ 3D Software                               ]" ON \
                    6 "usd opencv           [ usd, usd-devel, opencv                    ]" ON \
                    7 "XnView               [ fast image viewer                         ]" ON \
                    8 "non-Wayland apps     [ peek, flameshot                           ]" ON \
                    9 "ffmpeg               [ RPM Fusion ffmpeg with codecs             ]" ON \
                    3>&1 1>&2 2>&3)

        exit_status=$?

        if [ $exit_status -ne 0 ]; then
            break
        fi

        selections=($(echo $selections | tr -d '"'))
        log_action "Selected options: ${selections[*]}"
        install_selected_gfx_software "${selections[@]}"
    done
}

