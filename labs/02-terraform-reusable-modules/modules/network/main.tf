# Network module - Resources
#
# One virtual network, one subnet per entry in var.subnets, and one
# network security group associated with each subnet.

resource "azurerm_virtual_network" "this" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

# for_each creates one subnet per map entry. each.key is the subnet name.
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

# The NSG name is derived from the subnet name: snet-app-... becomes nsg-app-...
resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = "nsg-${trimprefix(each.key, "snet-")}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
