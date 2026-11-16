# Lab 03 - Module Versioning
#
# This root configuration consumes the network module from its own Git
# repository, at an explicit version tag.
#
# The state of this lab is separate from Labs 01 and 02.

# Authenticate with Azure CLI and confirm the subscription before planning.
# Never store credentials in Terraform source files.
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-lab03-network-dev-weu-001"
  location = var.location
  tags     = var.tags
}

# The ref argument pins the module to one Git tag.
# Changing the tag is a deliberate, reviewable change: one line in a pull request.
module "network" {
  source = "git::https://github.com/Solisys-Cloud/terraform-azurerm-network.git?ref=v1.0.0"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  virtual_network_name = "vnet-lab03-network-dev-weu-001"
  address_space        = var.address_space

  subnets = {
    "snet-app-dev-weu-001"  = { address_prefixes = ["10.30.1.0/24"] }
    "snet-mgmt-dev-weu-001" = { address_prefixes = ["10.30.2.0/24"] }
  }

  tags = var.tags
}
