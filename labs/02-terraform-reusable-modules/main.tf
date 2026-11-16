# Lab 02 - Terraform Reusable Modules
#
# This root configuration creates two resource groups and calls the same
# local module twice: once for dev and once for tst.
#
# The state of this lab is separate from Lab 01. Nothing here reads or
# changes the Lab 01 resources.

# Authenticate with Azure CLI and confirm the subscription before planning.
# Never store credentials in Terraform source files.
provider "azurerm" {
  features {}
}

# The root configuration owns the resource groups. The module receives
# their names, which keeps the module reusable in any resource group.
resource "azurerm_resource_group" "dev" {
  name     = "rg-lab02-network-dev-weu-001"
  location = var.location
  tags     = merge(var.tags, { environment = "dev" })
}

resource "azurerm_resource_group" "tst" {
  name     = "rg-lab02-network-tst-weu-001"
  location = var.location
  tags     = merge(var.tags, { environment = "tst" })
}

# First call: the dev network.
module "network_dev" {
  source = "./modules/network"

  resource_group_name  = azurerm_resource_group.dev.name
  location             = azurerm_resource_group.dev.location
  virtual_network_name = "vnet-lab02-network-dev-weu-001"
  address_space        = var.dev_address_space

  subnets = {
    "snet-app-dev-weu-001"  = { address_prefixes = ["10.20.1.0/24"] }
    "snet-mgmt-dev-weu-001" = { address_prefixes = ["10.20.2.0/24"] }
  }

  tags = merge(var.tags, { environment = "dev" })
}

# Second call: the same code, different inputs.
module "network_tst" {
  source = "./modules/network"

  resource_group_name  = azurerm_resource_group.tst.name
  location             = azurerm_resource_group.tst.location
  virtual_network_name = "vnet-lab02-network-tst-weu-001"
  address_space        = var.tst_address_space

  subnets = {
    "snet-app-tst-weu-001"  = { address_prefixes = ["10.21.1.0/24"] }
    "snet-mgmt-tst-weu-001" = { address_prefixes = ["10.21.2.0/24"] }
  }

  tags = merge(var.tags, { environment = "tst" })
}
