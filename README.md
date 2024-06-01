# Reinstall Setup

## About
You know the feeling when you have to re-install your system because something broke, and you struggle to remember what you had installed and how it was set up? This script helps you streamline the process, based on Thomas E. Dickey's [dialog package](https://invisible-island.net/dialog).

Inside `/scripts/submenu_template.sh` there is a template example of how to create a simple submenu tailored to your needs.

Inspired by [fedorable](https://github.com/smittix/fedorable), initially forked but then I re-wrote most of it for own needs.

<p align="center">
  <img src="../../wiki/images/hero_screenshot.png" alt="main_screenshot" />
</p>

## Usage
For detailed instructions, please check out the project [WIKI page](../../wiki).
Start by running `init_system.sh` script.
```bash
./init_system.sh
```

## Features
- Store current user dnf/flatpak/gnome extensions package list
- Install dnf/flatpak/gnome extensions packages from the list
- Edit and choose dnf/flatpak/gnome extensions package list file
- Install non-dnf packages and their repos (e.g., Google Chrome, VSCode, Sublime)
- Easy way to view logs
- Provided template for easy submenu creation

## Files
For detailed instructions on how to use these, please refer to the project [WIKI page](../../wiki/Package-and-Extension-files).
- **flatpak-packages.txt**: Contains a list of all flatpak packages to install. [Read More](../../wiki/Package-and-Extension-files#dnf-package-list)
- **dnf-packages.txt**: Contains a list of all dnf applications to be installed. [Read More](../../wiki/Package-and-Extension-files#flatpak-package-list)
- **gnome-extensions.txt**: Contains a list of all GNOME extensions to be installed on your system. [Read more](../../wiki/Package-and-Extension-files#gnome-extension-package-list)

## Installation
For installation instructions, please check out the project [WIKI page](../../wiki/Installation-and-Setup).

Navigate to the folder where you want to download this script:
```bash
cd ~/Downloads
git clone git@github.com:tmdag/reinstall_setup.git
```
### Screenshots
![Screenshot](../../wiki/images/gfx_software.png)
![Screenshot](../../wiki/images/dnf_package.png)
![Screenshot](../../wiki/images/file_edit.png)
![Screenshot](../../wiki/images/extensions.png)
![Screenshot](../../wiki/images/utilities.png)

