# Terraform Proxmox Module

This module is for creating Proxmox resources and supports provisioning via Ansible.

Right now this module only supports the creation of VMs with a Cloud-Init template as a base image, but I might add LXC support in the future.

## How does it work?

The module creates a VM and waits for the boot process to finish (This makes sure that there is no dpkg lock present which will break some Ansible tasks that use the apt module).
Since I haven't setup DHCP in my server VLANs, cloud-init behaves a little bit funky and refuses to apply the network config on the first boot. Due to this I have added a reboot before provisioning the VM.

After the reboot, the module will install all required roles listed in `ansible/requirements.yml` and execute the playbook defined in your module call.

Provisioning via Ansible is only possible if you configure a static IP for the VM. The IP is calculated via a given network and an ip index.
The networks have to be defined in the `locals.tf` and have to be mapped to a corresponding VLAN ID.

The module has the hostname, IP and the VM ID as output, so you can use it to create DNS entries with terraform or call other modules that need those values.

## Requirements

Terraform and Ansible have to be installed.

Cloud-Init VM template created on your Proxmox instance.

## How to use

Best way is to look at the example. The documentation for the variables in `variables.tf` should suffice to understand what each variable does.