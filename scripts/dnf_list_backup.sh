#!/bin/bash

host_name="myhost"
BACKUP_DEST_DIRECTORY="/home/$User/$host_name/"
FILENAME="dnf-packages_$(date +'%Y%m%d').txt"
LOG_FILE="/tmp/backup_package_list.log"

# Function to log messages
function dnf_list_log_message {
    echo "$(date): $1" >> "$LOG_FILE"
    chown ats:otters "$LOG_FILE"
}

create_repo_list_backup(){
    # Check if connected to the home network
    DIRECTORY="$BACKUP_DEST_DIRECTORY"
    # Check if the NFS directory is available
    if [ ! -d "$DIRECTORY" ]; then
        dnf_list_log_message "Directory $DIRECTORY does not exist. Backup omitted."
        exit 1
    fi

    # Generate the list of installed packages and save it to the file
    dnf repoquery --userinstalled --qf "@%{from_repo} %{name}" | grep -v -E "@(commandline|anaconda|kernel)" | grep -v " kernel" | sort > "${DIRECTORY}${FILENAME}"
    dnf_list_log_message "Backup completed successfully and saved to ${DIRECTORY}${FILENAME}"

}

create_repo_list_backup