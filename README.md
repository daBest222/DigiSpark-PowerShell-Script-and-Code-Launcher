# DigiSpark PowerShell Script and Code Launcher

This experimental project demonstrates how a DigiSpark USB device can act as a
keyboard to start a PowerShell-based setup workflow on a Windows computer. The
workflow reads a configuration file, can install selected dependencies and
download files, and can register tasks to run at startup.

## Project files

- [`DigiSpark_usb_code/DigiSpark_usb_code.ino`](DigiSpark_usb_code/DigiSpark_usb_code.ino)
  contains the DigiSpark sketch. It sends keyboard input to open PowerShell,
  downloads the configured setup and configuration files, and starts the setup
  process in a hidden window.
- [`Scripts/setup.ps1`](Scripts/setup.ps1) reads the configuration, handles
  dependency and file setup, and creates configured scheduled tasks. It writes
  progress to a log file.
- [`Scripts/config.jsonc`](Scripts/config.jsonc) specifies dependencies, files
  to download, and scheduled tasks.
- [`Scripts/main.py`](Scripts/main.py) is the example Python file currently
  listed in the configuration.
- [`Scripts/uninstall.ps1`](Scripts/uninstall.ps1) is intended to help undo
  setup changes.

This project is still in progress. Review the sketch, PowerShell scripts,
configuration, and any downloaded files before running anything; the workflow
can make persistent changes to a Windows system.

## Authorized use only

This project is for educational purposes. Use it only on your own device or on
devices for which you have explicit authorization. Do not use it to access,
modify, or run code on anyone else's device without permission.

Because the sketch launches commands and the setup workflow can create startup
tasks, do not connect or run it on a device unless you understand and have
approved the behavior.
