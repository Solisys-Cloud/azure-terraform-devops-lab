# Lab 04 - Terraform, AzureRM provider and remote backend requirements

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.13"
    }
  }

  # Partial backend configuration.
  # The storage account, container and key are passed at init time with
  # -backend-config, so this file contains no environment-specific values.
  backend "azurerm" {}
}
