#!/bin/bash

add_mplay_app(){
	# Find the highest version of Houdini installed under /opt/hfs*
	HFS_DIR=$(ls -d /opt/hfs* 2>/dev/null | sort -V | tail -n 1)

	# Check if any Houdini installation was found
	if [ -z "$HFS_DIR" ]; then
		echo "No Houdini installation found under /opt/hfs*."
		exit 1
	fi

	MPLAY_DIR="$HFS_DIR/bin/mplay"
	HOUDINI_LOGO="$HFS_DIR/houdini_logo.png"
	DESKTOP_FILE="/usr/share/applications/mplay.desktop"

	# Check if Mplay exists in the determined directory
	if [ ! -f "$MPLAY_DIR" ]; then
		echo "Mplay not found in $MPLAY_DIR. Please check the installation and try again."
		exit 1
	fi

	# Create the .desktop file content
	DESKTOP_ENTRY="[Desktop Entry]
	Name=SideFX Mplay
	Comment=Open and view .exr, .hdr images, and movie files with Mplay
	Exec=sh -c 'cd \"\$(dirname \"\$1\")\" && $MPLAY_DIR -g \"\$1\"' _ %f
	Icon=$HOUDINI_LOGO
	Terminal=false
	Type=Application
	MimeType=image/exr;image/vnd.radiance;video/x-msvideo;video/mp4;video/quicktime;video/x-matroska;video/x-flv;video/x-mpeg2;video/x-ms-wmv;video/webm;
	Categories=Graphics;Viewer;Video;
	"

	# Write the content to a temporary file
	TEMP_FILE=$(mktemp)
	echo "$DESKTOP_ENTRY" > "$TEMP_FILE"

	# Copy the .desktop file to /usr/share/applications with sudo
	echo "Copying .desktop file to /usr/share/applications..."
	sudo cp "$TEMP_FILE" "$DESKTOP_FILE"
	if [ $? -eq 0 ]; then
		echo "Desktop entry for Mplay created successfully."
	else
		echo "Failed to create desktop entry for Mplay."
	fi

	# Add mplay to /usr/local/bin/mplay
	if sudo ln -sf "$MPLAY_DIR" /usr/local/bin/mplay; then
		echo "Symlink for mplay created successfully."
	else
		echo "Failed to create symlink for mplay."
	fi

	# Clean up
	rm "$TEMP_FILE"
}