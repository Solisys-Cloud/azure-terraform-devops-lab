# Lab 01 - Azure Networking Fundamentals
#
# This configuration creates one resource group, one virtual network,
# two subnets, and one network security group per subnet.
#
# Resource names and address ranges come from variables.tf.
# No virtual machines, public IP addresses, or custom security rules
# are created by this lab.

# Authenticate locally using Azure CLI or supported ARM_* environment
# variables. Confirm the intended subscription before terraform plan.
# Never store credentials in Terraform source files.
provider "azurerm" {
  features {}
}

# 1. Resource group: the logical container for the lab.
resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# 2. Virtual network: the parent address space for both subnets.
resource "azurerm_virtual_network" "lab" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}

# 3. Application subnet: 10.10.1.0/24 by default.
resource "azurerm_subnet" "app" {
  name                 = var.app_subnet_name
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = var.app_subnet_address_prefixes
}

# 4. Management subnet: 10.10.2.0/24 by default.
resource "azurerm_subnet" "mgmt" {
  name                 = var.mgmt_subnet_name
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = var.mgmt_subnet_address_prefixes
}

# 5. Network security group for the application subnet.
# Only the default Azure NSG rules are present in this introductory lab.
resource "azurerm_network_security_group" "app" {
  name                = var.app_nsg_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

# 6. Network security group for the management subnet.
resource "azurerm_network_security_group" "mgmt" {
  name                = var.mgmt_nsg_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = var.tags
}

# 7. Associate the application NSG with the application subnet.
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# 8. Associate the management NSG with the management subnet.
resource "azurerm_subnet_network_security_group_association" "mgmt" {
  subnet_id                 = azurerm_subnet.mgmt.id
  network_security_group_id = azurerm_network_security_group.mgmt.id
}

# Security note: default NSG rules allow some traffic inside a virtual
# network. Two subnets alone are not equivalent to network isolation.
# A later lab will introduce explicit security rules and verification.
