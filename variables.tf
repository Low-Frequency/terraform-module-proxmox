### General Variables

variable "name" {
  description     = "Name of the Virtual Machine"
  type            = string
}

variable "description" {
  description     = "Text that should appear in the notes section. Optional"
  type            = string
  default         = null
}

variable "id" {
  description     = "ID of the created VM. 0 for next free ID"
  type            = number
  default         = 0
}

variable "target_node" {
  description     = "Cluster node on which the VM should be deployed"
  type            = string
}

variable "tags" {
  description     = "Tags to add to the VM. Only Meta Data"
  type            = string
  default         = null
}

### VM Hardware

variable "memory" {
  description     = "RAM of the VM"
  type            = number
  default         = 1024
}

variable "sockets" {
  description     = "Number of CPU sockets"
  type            = number
  default         = 1
}

variable "cores" {
  description     = "Number of CPU Cores"
  type            = number
  default         = 1
}

variable "cpu" {
  description     = "Type of CPU to emulate. Host for better performance"
  type            = string
  default         = "host"
}

variable "scsihw" {
  description     = "Type of SCSI Hardware to emulate"
  type            = string
  default         = "virtio-scsi-pci"
}

variable "disk" {
  description     = "List of disks"
  type            = list(object({
    disk_type     = optional(string, "scsi")
    storage_pool  = optional(string, "local-lvm")
    disk_size     = string
    ssd           = optional(number, 1)
    discard       = optional(string, "on")
  }))
  default = [ {
    disk_size     = "16G"
  } ]
}

variable "usb" {
  description     = "USB Device to be handed to the VM. Doesn't work right now due to a bug in the Proxmox API"
  type            = list(object({
    host          = string
    usb3          = bool
  }))
  default         = null
}

### Startup

variable "bios" {
  description     = "Underlying BIOS"
  type            = string
  default         = "seabios"
}

variable "onboot" {
  description     = "Start VM on boot of node"
  type            = bool
  default         = true
}

variable "startup" {
  description     = "Boot order of the VM. Can be 'order=number' or empty for any"
  type            = string
  default         = ""
}

variable "boot" {
  description     = "Order of the Drives to be booted from"
  type            = string
  default         = "order=scsi0;ide2;net0"
}

variable "agent" {
  description     = "Set status for qemu agent. 1 = enabled, 0 = disabled"
  type            = number
  default         = 1
}

### OS Settings

variable "iso" {
  description     = "ISO Image to boot from. Has to be uncommented in the main.tf if you want to use it. Comment the template line instead"
  type            = string
}

variable "template" {
  description     = "Template to use as base image"
  type            = string
}

variable "full_clone" {
  description     = "Control if the VM is a full clone or a linked clone"
  type            = bool
  default         = true
}

variable "os_type" {
  description     = "Type of OS to provision"
  type            = string
  default         = "cloud-init"
}

### Cloud Init

variable "user" {
  description     = "Cloud Init User"
  type            = string
}

variable "password" {
  description     = "Cloud Init Password"
  type            =  string
  sensitive       = true
}

variable "searchdomain" {
  description     = "Domain which VM should be added to with Cloud Init"
  type            = string
}

variable "nameserver" {
  description     = "Nameserver that should be added via Cloud Init"
  type            = string
}

variable "sshkeys" {
  description     = "SSH Key to be added to the VM"
  type            = string
}

variable "ip" {
  description     = "IP address with CIDR style subnet mask (10.11.12.13/14)"
  type            = string
  default         = "dhcp"
}

variable "gateway" {
  description     = "IP of the standard gateway"
  type            = string
  default         = null
}

### Networking

variable "nic_model" {
  description     = "NIC Model to be used"
  type            = string
  default         = "virtio"
}

variable "bridge" {
  description     = "Bridge to which the VM should be connected"
  type            = string
  default         = "vmbr0"
}

variable "vlan_tag" {
  description     = "VLAN Tag for the VM. -1 to turn VLAN Tagging off"
  type            = number
  default         = -1
}

variable "firewall" {
  description     = "Define if the firewall should be used"
  type            = bool
  default         = true
}

### Ansible Variables

variable "enable_ansible" {
  description     = "Enable Ansible playbook exexution on the host"
  type            = bool
  default         = false
}

variable "ansible_dir" {
  description     = "Ansible directory where playbook is located"
  type            = string
  default         = "ansible"
}

variable "ansible_requirements_file" {
  description     = "Requirements file for Roles to install. Relative to ansible_dir"
  type            = string
  default         = "requirements.yml"
}

variable "ansible_playbook" {
  description     = "Playbook to be used. Relative to ansible_dir"
  type            = string
  default         = "playbook.yml"
}

variable "private_key" {
  description     = "Path to private key file"
  type            = string
  default         = "~/.ssh/id_rsa"
}

variable "ansible_object_vars" {
  description     = "Ansible Variables"
  type            = map(any)
  default         = {}
}

variable "ansible_plain_vars" {
  description     = "Ansible Variables"
  type            = map(string)
  default         = {}
}

variable "ansible_debug" {
  description     = "Trigger verbose output of ansible"
  type            = bool
  default         = false
}
