output "ip_address" {
  description = "IP of the created VM"
  value       = local.ip_address
}

output "hostname" {
  description = "Hostname of the created VM"
  value       = var.name
}

output "vm_id" {
  description = "ID of the created VM"
  value       = local.vm_id
}
