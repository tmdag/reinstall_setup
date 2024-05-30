#!/bin/bash


# Get list of currently mounted NFS filesystems
NFS_MOUNTS=($(mount -t nfs,nfs4 | awk '{print $3}'))

add_nfs_to_tracker(){
    # Create the configuration directory if it doesn't exist
    CONFIG_DIR="$HOME/.config/tracker3/miners"
    mkdir -p "$CONFIG_DIR"

    # Create or update the user-places.json file
    CONFIG_FILE="$CONFIG_DIR/user-places.json"

    # Initialize an empty array to hold existing entries
    existing_entries=()

    # Check if the config file already exists and read existing entries
    if [[ -f "$CONFIG_FILE" ]]; then
        existing_entries=($(jq -r '.["network-directories"][]' "$CONFIG_FILE"))
    fi

    # Combine existing and new entries, then sort and remove duplicates
    all_entries=("${existing_entries[@]}" "${NFS_MOUNTS[@]}")
    unique_entries=($(echo "${all_entries[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

    # Write the updated configuration to the file
    {
        echo "{"
        echo '    "index-removable-devices": true,'
        echo '    "index-optical-discs": true,'
        echo '    "index-network": true,'
        echo '    "network-directories": ['
        for i in "${!unique_entries[@]}"; do
            if [[ $i -eq ${#unique_entries[@]}-1 ]]; then
                echo "        \"${unique_entries[$i]}\""
            else
                echo "        \"${unique_entries[$i]}\","
            fi
        done
        echo '    ]'
        echo "}"
    } > "$CONFIG_FILE"

    # Restart the tracker daemon to apply changes
    tracker3 daemon -k
    tracker3 daemon -s

    echo "Tracker configuration updated and daemon restarted."
}