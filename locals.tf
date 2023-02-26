locals {
  ### Calculating networking variables
  network_list = {
    vlan_10 = "10.10.10.0/24"
    vlan_20 = "10.10.20.0/24"
    vlan_30 = "10.10.30.0/24"
    vlan_40 = "10.10.40.0/24"
    vlan_50 = "10.10.50.0/24"
    vlan_60 = "10.10.60.0/24"
    vlan_70 = "10.10.70.0/24"
    vlan_80 = "10.10.80.0/24"
    vlan_90 = "10.10.90.0/24"
  }
  vlan_list = {
    vlan_10 = "10"
    vlan_20 = "20"
    vlan_30 = "30"
    vlan_40 = "40"
    vlan_50 = "50"
    vlan_60 = "60"
    vlan_70 = "70"
    vlan_80 = "80"
    vlan_90 = "90"
  }
  vlan_id         = lookup(local.vlan_list, var.network, 800)
  network_address = lookup(local.network_list, var.network, "10.10.100.0/24")
  cidr_mask       = split("/", local.network_address)[1]
  ip_address      = var.enable_dhcp ? "dhcp" : cidrhost(local.network_address, var.ip_index)
  gateway_ip      = local.ip_address == "dhcp" ? "" : cidrhost(local.network_address, 1)
  ipconfig        = local.ip_address == "dhcp" ? "ip=${local.ip_address}" : "ip=${local.ip_address}/${local.cidr_mask},gw=${local.gateway_ip}"
  nameserver      = var.nameserver != null ? var.nameserver : "${local.gateway_ip}"
  vm_id           = local.vlan_id + var.ip_index

  ### Ansible Playbook execution
  ansible_vars  = jsonencode(var.ansible_object_vars) == "{}" ? jsonencode(var.ansible_plain_vars) : (jsonencode(var.ansible_plain_vars) == "{}" ? jsonencode(var.ansible_object_vars) : replace(jsonencode(var.ansible_object_vars), "/}$/", replace(jsonencode(var.ansible_plain_vars), "/^{/", ",")))
  ansible_debug = var.ansible_debug ? "-vvv" : ""

  ### Auto Shutdown
  reboot_vars = {
    server_name     = var.name
    server_id       = local.vm_id
    shutdown_hour   = split(":", var.shutdown_time)[0]
    shutdown_minute = split(":", var.shutdown_time)[1]
    start_hour      = split(":", var.start_time)[0]
    start_minute    = split(":", var.start_time)[1]
  }
  reboot_ansible_vars = jsonencode(local.reboot_vars)
}
