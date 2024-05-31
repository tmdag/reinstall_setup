
## About:
You know the feeling when you have to re-install system as something broke, remembering what you have installed and how it was setup ?
Here is an easy way to put together all nessecery steps to bring your system where it was.

Inside /scripts/submenu_template.sh there is a template example how to create simple sub menu tailored for your own needs.

Inspired by https://github.com/smittix/fedorable, intially forked but then, I have created own version from scratch.

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

- **flatpak-packages.txt** - This file contains a list of all flat packages to install you can customise this manually or directly via app.
- **dnf-packages.txt** - This file contains a list of all applications that will be installed in a format of "@repository package_name".

## Screenshot
![Screenshot](screenshot_main_menu.png)
![Screenshot](screenshot_gfx_software.png)
![Screenshot](screenshot_dnf_package)
![Screenshot](screenshot_file_edit.png)
![Screenshot](screenshot_utilities.png)
