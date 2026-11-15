# Lab 01 - Terraform outputs
#
# Outputs display useful details after a successful terraform apply.
# During terraform plan, values that are not yet known are shown as
# "known after apply". None of the outputs below contain credentials.

output "resource_group_name" {
  description = "Name of the resource group hosting the lab."
  value       = azurerm_resource_group.lab.name
}

output "resource_group_id" {
  description = "Azure resource ID of the lab resource group."
  value       = azurerm_resource_group.lab.id
}

output "virtual_network_id" {
  description = "Azure resource ID of the virtual network."
  value       = azurerm_virtual_network.lab.id
}

output "virtual_network_address_space" {
  description = "Address spaces assigned to the virtual network."
  value       = azurerm_virtual_network.lab.address_space
}

output "app_subnet_id" {
  description = "Azure resource ID of the application subnet."
  value       = azurerm_subnet.app.id
}

output "mgmt_subnet_id" {
  description = "Azure resource ID of the management subnet."
  value       = azurerm_subnet.mgmt.id
}

output "app_nsg_id" {
  description = "Azure resource ID of the application network security group."
  value       = azurerm_network_security_group.app.id
}

output "mgmt_nsg_id" {
  description = "Azure resource ID of the management network security group."
  value       = azurerm_network_security_group.mgmt.id
}
