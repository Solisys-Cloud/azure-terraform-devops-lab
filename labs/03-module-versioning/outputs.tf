# Lab 03 - Outputs

output "virtual_network_id" {
  description = "Azure resource ID of the virtual network."
  value       = module.network.virtual_network_id
}

output "subnet_ids" {
  description = "Subnet IDs, by subnet name."
  value       = module.network.subnet_ids
}
