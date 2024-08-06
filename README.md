# ubuntu-kr-qr-kiosk [![CircleCI](https://dl.circleci.com/status-badge/img/circleci/LCy26Fe3U1mrPC75gaG7e1/K8Lwqp1Yg1mdDbFWcENXcQ/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/circleci/LCy26Fe3U1mrPC75gaG7e1/K8Lwqp1Yg1mdDbFWcENXcQ/tree/main)

A Check-in kiosk app built with Flutter for Ubuntu Frame and Ubuntu Core environment

## Building Snap
Simply run `snapcraft` where `snapcraft`, `snap` and `lxd` are installed.

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

## Building custom ubuntu core image

Install `ubuntu-image`

```bash
sudo snap install ubuntu-image --classic
```

In `snap/ubuntu-core-model.json` change `authority-id` and `brand-id` to your `id` found from the `snapcraft whoami` command output. Below is an example of `snapcraft whoami` output.

```bash
$ snapcraft whoami
email: <email-address>
username: <username>
id: xSfWKGdLoQBoQx88
permissions: package_access, package_manage, package_metrics, package_push, package_register, package_release, package_update
channels: no restrictions
expires: 2024-04-17T10:25:13.675Z 
```

Create and register key for snap signing if you don't have one yet.

```bash
snapcraft create-key my-model-key
snapcraft register-key my-model-key
```

Update `timestamp` field of `snap/ubuntu-core-model.json`. You may get timestamp from `date -Iseconds --utc` command.

Sign the model so that we can create custom core image.
```bash
snap sign -k my-model-key snap/ubuntu-core-model.json > snap/ubuntu-core-model.model
```

Add Kiosk Snap and Custom Pi Gadget with following command

```bash
ubuntu-image snap snap/ubuntu-core-model.model --snap <snap_file_name>
```

Finally, build the custom ubuntu core image
```bash
ubuntu-image snap snap/ubuntu-core-model.model
```