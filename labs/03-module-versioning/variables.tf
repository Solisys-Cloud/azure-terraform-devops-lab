# Lab 03 - Input variables

variable "location" {
  description = "Azure region in which the lab resources are created."
  type        = string
  default     = "westeurope"
}

variable "address_space" {
  description = "Address space of the lab virtual network."
  type        = list(string)
  default     = ["10.30.0.0/16"]
}

variable "tags" {
  description = "Common Azure tags used to identify lab resources."
  type        = map(string)

  default = {
    environment = "dev"
    project     = "lab03-module-versioning"
    managed_by  = "terraform"
  }
}
