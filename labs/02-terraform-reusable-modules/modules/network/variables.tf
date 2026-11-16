# Network module - Inputs
#
# The module does not create the resource group. The caller decides where
# the network lives and passes the resource group name and the region.

variable "resource_group_name" {
  description = "Name of an existing resource group in which the network is created."
  type        = string
}

variable "location" {
  description = "Azure region of the network resources."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address spaces of the virtual network, in CIDR notation."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "address_space must contain at least one valid CIDR block, for example 10.20.0.0/16."
  }
}

variable "subnets" {
  description = "Subnets to create. The map key is the subnet name; the value holds its address prefixes."
  type = map(object({
    address_prefixes = list(string)
  }))

  validation {
    condition     = alltrue([for name, subnet in var.subnets : startswith(name, "snet-")])
    error_message = "Every subnet name must start with the prefix snet-."
  }
}

variable "tags" {
  description = "Tags applied to every resource that supports them."
  type        = map(string)
  default     = {}
}
