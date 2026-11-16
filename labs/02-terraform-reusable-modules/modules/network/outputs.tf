# Network module - Outputs
#
# Outputs are the only values a caller can read from a module.

output "virtual_network_id" {
  description = "Azure resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "virtual_network_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet names to subnet resource IDs."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "network_security_group_ids" {
  description = "Map of subnet names to the resource ID of their network security group."
  value       = { for name, nsg in azurerm_network_security_group.this : name => nsg.id }
}
