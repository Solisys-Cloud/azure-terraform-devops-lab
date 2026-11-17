# Lab 04 - Input variables

variable "location" {
  description = "Azure region in which the lab resources are created."
  type        = string
  default     = "westeurope"
}

variable "address_space" {
  description = "Address space of the lab virtual network."
  type        = list(string)
  default     = ["10.40.0.0/16"]
}

variable "tags" {
  description = "Common Azure tags used to identify lab resources."
  type        = map(string)

  default = {
    environment = "dev"
    project     = "lab04-azure-devops-cicd"
    managed_by  = "terraform"
    deployed_by = "azure-pipelines"
  }
}
