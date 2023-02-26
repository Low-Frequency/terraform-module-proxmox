### VM creation
resource "proxmox_vm_qemu" "vm" {
  # General VM Settings
  name        = var.name
  desc        = var.description
  vmid        = local.vm_id
  target_node = var.target_node
  tags        = var.network
 
  # Startup
  bios    = var.bios
  onboot  = var.onboot
  startup = var.startup
  boot    = var.boot
  agent   = var.agent

  # OS Settings
  # iso      = var.vm_iso
  clone      = var.template
  full_clone = var.full_clone
  os_type    = var.os_type

  # Hardware
  memory  = var.memory
  sockets = var.sockets
  cores   = var.cores
  cpu     = var.cpu
  scsihw  = var.scsihw

  dynamic "disk" {
    for_each = var.disk

    content {
      type    = disk.value.disk_type
      storage = disk.value.storage_pool
      size    = disk.value.disk_size
      ssd     = disk.value.ssd
      discard = disk.value.discard
    }
  }

  dynamic "usb" {
    for_each = var.usb == null ? [] : var.usb
    
    content {
      host = usb.value.host
      usb3 = usb.value.usb3
    }
  }

  # Cloud Init
  ciuser       = var.user
  cipassword   = var.password
  searchdomain = var.searchdomain
  nameserver   = local.nameserver
  sshkeys      = var.sshkeys
  ipconfig0    = local.ipconfig

  # Networking
  network {
    model    = var.nic_model
    bridge   = var.bridge
    tag      = local.vlan_id
    firewall = var.firewall
  }
}

### Wait for first Boot Process
### Without DHCP setup, cloud-init is somehow unable to apply the IP address to the VM
### A reboot however will apply the network config through cloud-init
### This sleep makes sure the VM boots completely before rebooting it to apply the network config
resource "time_sleep" "first_boot" {
  count = var.enable_ansible || ! var.enable_dhcp ? 1 : 0
  
  create_duration = "150s"
  
  depends_on = [
    proxmox_vm_qemu.vm
  ]
}

### Reboot VM to apply cloud-init network config
resource "null_resource" "reboot_vm" {
  count = var.enable_dhcp ? 0 : 1

  provisioner "local-exec" {
    command = <<EOF
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible all -i '${var.proxmox_host_address},' \
      -u '${var.ansible_user}' \
      --private-key '${var.ansible_ssh_key_path}' \
      -a 'sudo qm reboot ${local.vm_id}'
      EOF
  }

  depends_on = [
    time_sleep.first_boot
  ]
}

### Waiting again to make sure the VM is fully started before provisioning
resource "time_sleep" "restart" {
  count = var.enable_ansible && ! var.enable_dhcp ? 1 : 0
  
  create_duration = "150s"
  
  depends_on = [
    null_resource.reboot_vm
  ]
}

### Provision VM
resource "null_resource" "ansible" {
  count = var.enable_ansible && ! var.enable_dhcp ? 1 : 0
  
  triggers = {
    variables = local.ansible_vars
  }

  provisioner "remote-exec" {
    inline = [
      "echo Provisioning!"
    ]

    connection {
      host        = local.ip_address
      type        = "ssh"
      user        = "${var.ansible_user}"
      private_key = file(var.ansible_ssh_key_path)
    }
  }

  provisioner "local-exec" {
    command = <<EOF
      chmod 755 ${var.ansible_dir} && \
      cd ${var.ansible_dir} && \
      ansible-galaxy install -r ${var.ansible_requirements_file} -p roles && \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -u '${var.ansible_user}' \
      --private-key '${var.ansible_ssh_key_path}' \
      -e '${local.ansible_vars}' \
      -i '${local.ip_address},' \
      ${var.ansible_playbook} \
      ${local.ansible_debug}
      EOF
  }

  depends_on = [
    time_sleep.restart
  ]
}

### Create reboot schedule
resource "null_resource" "reboot_schedule" {
  count    = var.enable_auto_reboot ? 1 : 0

  triggers = {
    ansible_variables = local.reboot_ansible_vars
    ansible_directory = var.ansible_dir
  }

  provisioner "local-exec" {
    command = <<EOF
      chmod 755 ${self.triggers.ansible_directory} && \
      cd ${self.triggers.ansible_directory} && \
      find ../.terraform/modules -type f -name auto_reboot.yml -exec cp "{}" . \; && \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -u '${var.ansible_user}' \
      --private-key '${var.ansible_ssh_key_path}' \
      -i '${var.proxmox_host_address},' \
      -e '${self.triggers.ansible_variables}' \
      -e "reboot_cron_state=present" \
      auto_reboot.yml
      EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      chmod 755 ${self.triggers.ansible_directory} && \
      cd ${self.triggers.ansible_directory} && \
      find ../.terraform/modules -type f -name auto_reboot.yml -exec cp "{}" . \; && \
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -u '${var.ansible_user}' \
      --private-key '${var.ansible_ssh_key_path}' \
      -i '${var.proxmox_host_address},' \
      -e '${self.triggers.ansible_variables}' \
      -e "reboot_cron_state=absent" \
      auto_reboot.yml
      EOF
  }

  depends_on = [
    proxmox_vm_qemu.vm
  ]
}
