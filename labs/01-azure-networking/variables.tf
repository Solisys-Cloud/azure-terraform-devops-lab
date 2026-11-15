# Lab 01 - Input variables
#
# These inputs make the learning environment easy to customize without
# editing the resource definitions in main.tf.
# The defaults match the architecture documented in the lab README.

variable "location" {
  description = "Azure region in which the lab resources will be created."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group containing the lab resources."
  type        = string
  default     = "rg-lab01-network-dev-weu-001"
}

variable "virtual_network_name" {
  description = "Name of the Azure virtual network."
  type        = string
  default     = "vnet-lab01-network-dev-weu-001"
}

variable "virtual_network_address_space" {
  description = "Address space assigned to the virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "app_subnet_name" {
  description = "Name of the application subnet."
  type        = string
  default     = "snet-app-dev-weu-001"
}

variable "app_subnet_address_prefixes" {
  description = "Address prefixes assigned to the application subnet."
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "mgmt_subnet_name" {
  description = "Name of the management subnet."
  type        = string
  default     = "snet-mgmt-dev-weu-001"
}

variable "mgmt_subnet_address_prefixes" {
  description = "Address prefixes assigned to the management subnet."
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

variable "app_nsg_name" {
  description = "Name of the network security group associated with the application subnet."
  type        = string
  default     = "nsg-app-dev-weu-001"
}

variable "mgmt_nsg_name" {
  description = "Name of the network security group associated with the management subnet."
  type        = string
  default     = "nsg-mgmt-dev-weu-001"
}

variable "tags" {
  description = "Common Azure tags used to identify lab resources."
  type        = map(string)

  default = {
    environment = "dev"
    project     = "lab01-azure-networking"
    managed_by  = "terraform"
  }
}
