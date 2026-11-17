# Lab 04 - Terraform CI/CD with Azure Pipelines
#
# The infrastructure is intentionally small: the network module of Lab 03,
# pinned at v1.0.0. The subject of this lab is the delivery process around it.
#
# In the pipeline, the provider authenticates with workload identity federation
# (OpenID Connect) through ARM_* environment variables. On a workstation, it uses
# your Azure CLI sign-in. No credential is ever stored in this code.

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-lab04-network-dev-weu-001"
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "git::https://github.com/Solisys-Cloud/terraform-azurerm-network.git?ref=v1.0.0"

  resource_group_name  = azurerm_resource_group.this.name
  location             = azurerm_resource_group.this.location
  virtual_network_name = "vnet-lab04-network-dev-weu-001"
  address_space        = var.address_space

  subnets = {
    "snet-app-dev-weu-001"  = { address_prefixes = ["10.40.1.0/24"] }
    "snet-mgmt-dev-weu-001" = { address_prefixes = ["10.40.2.0/24"] }
  }

  tags = var.tags
}
