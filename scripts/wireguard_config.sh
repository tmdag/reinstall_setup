#!/bin/bash

log_action "sourced wireguard_config.sh"

# Get the directory of the sourced script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

install_wireguard() {
    clear
    log_action "Installing Wireguard"
    sudo dnf install -y wireguard &>> $LOG_FILE
    log_action "Installation fo wireguard complete"
}

save_wireguard_config() {
    clear
    local config_dir="/etc/wireguard"
    local hostname=$(hostname)  

    if [[ ! -d "$config_dir" ]]; then
        notify "Configuration directory not found: $config_dir"
        log_action "Configuration directory not found: $config_dir"
        return 1
    fi

    local destination_folder="$SCRIPT_DIR/../personal"
    if [[ ! -d "$destination_folder" ]]; then
        mkdir -p "$destination_folder"
        if [[ $? -ne 0 ]]; then
            notify "Failed to create directory: $destination_folder"
            log_action "Failed to create directory: $destination_folder"
            return 1
        fi
    fi

    log_action "Reading existing WireGuard configuration from: $config_dir"

    local config_file
    config_file=$(sudo find "$config_dir" -name '*.conf' -print -quit)

    if [[ -z "$config_file" ]]; then
        notify "No configuration file found in: $config_dir"
        log_action "No configuration file found in: $config_dir"
        return 1
    fi

    log_action "Found configuration file: ${config_file}"

    if sudo test -f "$config_file"; then
        local base_name=$(basename "$config_file" .conf)
        local destination_file="$destination_folder/${base_name}_${hostname}.conf"

        log_action "Saving $config_file to $destination_file"
        sudo cp "$config_file" "$destination_file"
        sudo chown $USER:$USER "$destination_file"
        if [[ $? -eq 0 ]]; then
            notify "Configuration saved to: $destination_file"
            log_action "Configuration saved to: $destination_file"
        else
            notify "Failed to save configuration: $config_file"
            log_action "Failed to save configuration: $config_file"
            return 1
        fi
    else
        notify "No valid configuration file found in $config_dir"
        log_action "No valid configuration file found in $config_dir"
    fi
}

apply_wireguard_config() {
    local config_file

    config_file=$(dialog --stdout --title "Select WireGuard Configuration" --fselect "$SCRIPT_DIR/../personal/" 14 48)
    if [[ -z "$config_file" ]]; then
        notify "No configuration file selected."
        return 1
    fi

    if [[ ! -f "$config_file" ]]; then
        notify "Configuration file not found: $config_file"
        return 1
    fi

    log_action "Applying WireGuard configuration: $config_file"
    sudo wg-quick up "$config_file"

    if [[ $? -eq 0 ]]; then
        notify "WireGuard configuration applied successfully."
    else
        notify "Failed to apply WireGuard configuration."
        return 1
    fi
}

