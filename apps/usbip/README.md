# usbip

USB over IP:
* https://github.com/torvalds/linux/blob/master/tools/usb/usbip/README
* https://man.archlinux.org/man/extra/usbip/usbipd.8.en
* https://man.archlinux.org/man/extra/usbip/usbip.8.en

## Usbip server

Systemd service & udev rules for device binding:
* https://github.com/prehor/home-ops/blob/main/ansible/main/playbooks/cluster-prepare.yaml

## Usbip client

Kubernetes sidecar container:
* https://github.com/prehor/home-ops/blob/main/ansible/storage/playbooks/cluster-prepare.yaml
* https://github.com/prehor/home-ops/blob/main/kubernetes/main/apps/home-automation/home-assistant/app/helmrelease.yaml

