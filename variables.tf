### General Variables

variable "name" {
  description     = "Name of the Virtual Machine"
  type            = string
}

variable "description" {
  description     = "Text that should appear in the notes section"
  type            = string
  default         = null
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
    storage_pool  = optional(string, "local-zfs")
    disk_size     = string
    ssd           = optional(number, 1)
    discard       = optional(string, "on")
  }))
  default = [ {
    disk_size     = "16G"
  } ]
}

variable "usb" {
  description     = "USB Device to be handed to the VM"
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

  validation {
    condition     = (
      var.startup == "" ||
      ( substr(var.startup, 0, 6) == "order=" && length(regexall("[0-9]+", substr(var.startup, 6, 4))) > 0 )
    )
    error_message = "var.startup must be empty or has to be in the format 'order=NUMBER'."
  }
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
  description     = "ISO Image to boot from"
  type            = string
  default         = ""
}

variable "template" {
  description     = "Template to use as base image"
  type            = string
  default         = "ubuntu-2204"
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
  type            = string
  sensitive       = true
}

variable "searchdomain" {
  description     = "Domain which VM should be added to with Cloud Init"
  type            = string
  default         = null
}

variable "nameserver" {
  description     = "Nameserver that should be added via Cloud Init"
  type            = string
  default         = null
}

variable "sshkeys" {
  description     = "SSH Key to be added to the VM"
  type            = string
  default         = ""
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

variable "firewall" {
  description     = "Enable/disable firewall"
  type            = bool
  default         = true
}

variable "network" {
  description     = "Name of the network to join the VM"
  type            = string
  default         = "vlan_10"
}

variable "ip_index" {
  description     = "IP to assign in the respective network"
  type            = number
}

variable "enable_dhcp" {
  description     = "Set to true to enable DHCP"
  type            = bool
  default         = false
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
  description     = "Requirements file for Roles to install"
  type            = string
  default         = "requirements.yml"
}

variable "ansible_playbook" {
  description     = "Playbook to be used"
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

variable "ansible_user" {
  description     = "Ansible user"
  type            = string
  default         = "ansible"
}

variable "ansible_ssh_key_path" {
  description     = "Path to ansible SSH key"
  type            = string
  default         = "~/.ssh/id_rsa_ansible"
}

### Auto reboot 

variable "enable_auto_reboot" {
  description     = "Enable automatic reboot for the VM"
  type            = bool
  default         = false
}

variable "shutdown_time" {
  description     = "Time when the VM will be shut off"
  type            = string
  default         = "02:00"
}

variable "start_time" {
  description     = "Time when the VM will be powered on"
  type            = string
  default         = "08:00"
}

variable "proxmox_host_address" {
  description     = "FQDN or IP of the Proxmox host"
  type            = string
}
