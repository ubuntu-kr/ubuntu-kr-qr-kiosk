# ubuntu-kr-qr-kiosk [![CircleCI](https://dl.circleci.com/status-badge/img/circleci/LCy26Fe3U1mrPC75gaG7e1/K8Lwqp1Yg1mdDbFWcENXcQ/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/circleci/LCy26Fe3U1mrPC75gaG7e1/K8Lwqp1Yg1mdDbFWcENXcQ/tree/main)

A Check-in kiosk app built with Flutter for Ubuntu Frame and Ubuntu Core environment

## Setup

Install Ubuntu Frame, Ubuntu Frame OSK and Network Manager on Ubuntu Core 22+

```bash
sudo snap install ubuntu-frame ubuntu-frame-osk network-manager
```

Get Snap from Circle CI Build artifacts, Send it to remote machine then install.

```bash
scp -i <PATH_TO_SSH_KEY> ubuntu-kr-qr-kiosk_<version>_arm64.snap <USER>@<IP_ADDRESS>:~/
sudo snap install --dangerous ubuntu-kr-qr-kiosk_<version>_arm64.snap
```

Various interface connections are required to make kiosk app work. Use following commands to configure.

```bash
sudo /snap/ubuntu-kr-qr-kiosk/current/bin/setup.sh
```

Setup Kiosk server and api token
```bash
snap set ubuntu-kr-qr-kiosk server.host="http://localhost:8000"
snap set ubuntu-kr-qr-kiosk server.apitoken="12345"
```

Enable cursor on Ubuntu Frame
```bash
snap set ubuntu-frame config="cursor=auto"
```