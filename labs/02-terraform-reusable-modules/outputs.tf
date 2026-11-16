# Lab 02 - Outputs
#
# A root output can only expose what the module declares as an output.

output "dev_virtual_network_id" {
  description = "Azure resource ID of the dev virtual network."
  value       = module.network_dev.virtual_network_id
}

output "dev_subnet_ids" {
  description = "Subnet IDs of the dev network, by subnet name."
  value       = module.network_dev.subnet_ids
}

output "tst_virtual_network_id" {
  description = "Azure resource ID of the tst virtual network."
  value       = module.network_tst.virtual_network_id
}

output "tst_subnet_ids" {
  description = "Subnet IDs of the tst network, by subnet name."
  value       = module.network_tst.subnet_ids
}
