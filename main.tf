## VM creation
resource "proxmox_vm_qemu" "vm" {
  # General VM Settings
  name        = var.name
  desc        = var.description
  vmid        = var.id
  target_node = var.target_node
  tags        = var.tags
 
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
  nameserver   = var.nameserver
  sshkeys      = var.sshkeys
  ipconfig0    = var.ip == "dhcp" ? "ip=${var.ip}" : "ip=${var.ip},gw=${var.gateway}"

  # Networking
  network {
    model    = var.nic_model
    bridge   = var.bridge
    tag      = var.vlan_tag
    firewall = var.firewall
  }
}

## Wait for Boot Process
resource "time_sleep" "boot_process" {
  count = var.enable_ansible && var.ip != "dhcp" ? 1 : 0
  
  create_duration = "300s"
  
  depends_on = [
    proxmox_vm_qemu.vm
  ]
}

## Ansible Playbook execution
locals {
  # There might be an easier way to make multiple datatypes for ansible vars work. If you know one, please let me know
  ansible_vars  = jsonencode(var.ansible_object_vars) == "{}" ? jsonencode(var.ansible_plain_vars) : (jsonencode(var.ansible_plain_vars) == "{}" ? jsonencode(var.ansible_object_vars) : replace(jsonencode(var.ansible_object_vars), "/}$/", replace(jsonencode(var.ansible_plain_vars), "/^{/", ",")))
  ip_address    = strrev(substr(strrev(var.ip), 3, 16))
  ansible_debug = var.ansible_debug ? "-vvv" : ""
}

resource "null_resource" "ansible" {
  count = var.enable_ansible && var.ip != "dhcp" ? 1 : 0
  
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
      user        = var.user
      private_key = file("${var.private_key}")
    }
  }

  provisioner "local-exec" {
    command = <<EOF
chmod 755 ${var.ansible_dir} && \
cd ${var.ansible_dir} && \
ansible-galaxy install -r ${var.ansible_requirements_file} -p roles && \
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u '${var.user}' -e '${local.ansible_vars}' -i '${local.ip_address},' ${var.ansible_playbook} ${local.ansible_debug}
EOF
  }

  depends_on = [
    time_sleep.boot_process
  ]
}
