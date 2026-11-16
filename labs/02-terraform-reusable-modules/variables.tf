# Lab 02 - Input variables
#
# The defaults describe two small environments, dev and tst, that use the
# same module with different values.

variable "location" {
  description = "Azure region in which the lab resources are created."
  type        = string
  default     = "westeurope"
}

variable "dev_address_space" {
  description = "Address space of the dev virtual network."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "tst_address_space" {
  description = "Address space of the tst virtual network."
  type        = list(string)
  default     = ["10.21.0.0/16"]
}

variable "tags" {
  description = "Tags shared by both environments. The environment tag is added per environment."
  type        = map(string)

  default = {
    project    = "lab02-terraform-reusable-modules"
    managed_by = "terraform"
  }
}
