#!/bin/bash

# Use sudo SKIP_PACKAGE_CHECK=1 ./DaVinci.Resolve during installation to ignore package errors

fix_davinci_resolve() {

    local resolve_dir="/opt/resolve"
    local input_dir

    # dialog to confirm or edit installation path
    input_dir=$(dialog --inputbox "Confirm or edit DaVinci Resolve installation directory:" 10 50 "$resolve_dir" 3>&1 1>&2 2>&3 3>&-)

    # Exit if dialog is canceled
    if [[ $? -ne 0 ]]; then
        notify "Operation canceled by the user."
        return
    fi

    resolve_dir="$input_dir"

    if [[ -d "${resolve_dir}/libs" ]]; then
        sudo dnf install -y libxcrypt-compat libcurl libcurl-devel mesa-libGLU
        cd "${resolve_dir}/libs"
        sudo mkdir -p disabled-libraries
        sudo mv libglib* disabled-libraries
        sudo mv libgio* disabled-libraries
        sudo mv libgmodule* disabled-libraries
        notify "Libraries disabled successfully."
    else
        notify "Could not find resolve libs under ${resolve_dir}"
    fi
}
