
## About:
Inspired by https://github.com/smittix/fedorable, I have created own version from scratch, tailored for my needs.

A easy-to-use way to install all nessecery packages and setup system based on your own needs.

## Usage
1. Set the script to be executable `chmod -x init_system.sh`
2. Run the script `./init_system.sh`
3. Enter user password.

## Features:
- Store current user dnf/flatpak package list
- Install  dnf/flatpak  packages from the list
- Edit and choose  dnf/flatpak package list file
- Install non dnf packages and their repos (google-chrome, vscode, sublime)
- easy way to view logs
- provided template for easy sub-menu creation

## Files

- **flatpak-packages.txt** - This file contains a list of all flat packages to install you can customise this with your choice of applications by application-id.
- **dnf-packages.txt** - This file contains a list of all applications that will be installed in a format of "@repository package_name".

## Screenshot
![Screenshot](screenshot_main_menu.png)
![Screenshot](screenshot_gfx_software.png)
![Screenshot](screenshot_file_edit.png)
