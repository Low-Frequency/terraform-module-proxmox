# Outputs of the module

output "ip_address" {
  description = "IP address of the VM"
  value       = var.ip == "dhcp" ? null : strrev(substr(strrev(var.ip), 3, 16))
}

output "hostname" {
  description = "Hostname of the VM"
  value       = var.name
}
