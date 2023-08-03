# nametag_console

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Ubuntu dependencies

- libusb-1.0-0
- libusb-1.0-0-dev
- v4l-utils
- gstreamer1.0-plugins-good
- libsqlite3-dev
- Gstreamer: [See here](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c)

## Snap interface setup

USB and Camera interface connections are required to make kiosk app work. Use following commands to configure.

```bash
sudo snap connect ubuntu-kr-qr-kiosk:camera
sudo snap connect ubuntu-kr-qr-kiosk:raw-usb
```