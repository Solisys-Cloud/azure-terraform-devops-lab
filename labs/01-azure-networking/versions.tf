# Lab 01 - Terraform and AzureRM provider requirements
#
# This file declares which Terraform CLI and provider versions the lab accepts.
# It does not create Azure resources.

terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.13"
    }
  }
}

# The provider configuration and Azure subscription selection will be
# introduced in the next step, together with the first resources.
#
# Run 'terraform init' only after reviewing the repository .gitignore.
# Commit the resulting .terraform.lock.hcl, but never commit Terraform state.
