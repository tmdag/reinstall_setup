# Reinstall Setup

## About
You know the feeling when you have to re-install your system because something broke, and you struggle to remember what you had installed and how it was set up? This script helps you streamline the process, based on Thomas E. Dickey's [dialog package](https://invisible-island.net/dialog).

Inside `/scripts/submenu_template.sh` there is a template example of how to create a simple submenu tailored to your needs.

Inspired by [fedorable](https://github.com/smittix/fedorable), initially forked but then created my own version from scratch.

## Usage
For detailed instructions, please check out the project [WIKI page](../../wiki).

## Features
- Store current user dnf/flatpak package list
- Install dnf/flatpak packages from the list
- Edit and choose dnf/flatpak package list file
- Install non-dnf packages and their repos (e.g., Google Chrome, VSCode, Sublime)
- Easy way to view logs
- Provided template for easy submenu creation

## Files
For detailed instructions on how to use these, please refer to the project [WIKI page](../../wiki).
- **flatpak-packages.txt**: Contains a list of all flatpak packages to install. Customize this manually or via the app.
- **dnf-packages.txt**: Contains a list of all applications to be installed in the format of "@repository package_name".
- **gnome-extensions.txt**: Contains a list of all GNOME extensions to be installed on your system.

![Screenshot](../../wiki/images/hero_screenshot.png)

## Installation
For installation instructions, please check out the project [WIKI page](../../wiki).

Navigate to the folder where you want to download this script:

```bash
cd ~/Downloads
git clone git@github.com:tmdag/reinstall_setup.git


![Screenshot](../../wiki/images/gfx_software.png)
![Screenshot](../../wiki/images/dnf_package.png)
![Screenshot](../../wiki/images/file_edit.png)
![Screenshot](../../wiki/images/extensions.png)
![Screenshot](../../wiki/images/utilities.png)

