# Network module - Terraform and provider requirements
#
# A module declares the providers it needs, but it does not configure them.
# The provider block lives in the root configuration that calls the module.

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.13"
    }
  }
}
