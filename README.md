# Terraform Proxmox Module

This module is for creating Proxmox resources and supports provisioning via Ansible.

Right now this module only supports the creation of VMs, but I might add LXC support in the future.

## How does it work?

The module creates a VM and if activated waits for 5 minutes to finish the boot process (This makes sure that there is no dpkg lock present which will break some Ansible tasks that use the apt module. I haven't found a more elegant way to work around this, but if you know one please let me know).
After waiting for the boot process the module will install all required roles listed in the `requirements.yml` and execute the playbook defined in the `main.tf`.

Provisioning via Ansible is only possible if you configure a static IP for the VM. If you don't define an IP address it will default to DHCP and disable provisioning.

The module has the hostname and the IP of the VM as output, so you can use it to create DNS entries with terraform or call other modules that need those values.

## Requirements

Terraform and Ansible have to be installed.

To provision a VM you have to set up private key authentication first.

## How to use

Best way is to look at the example. The documentation for the variables in `variables.tf` should suffice to understand what each variable does.