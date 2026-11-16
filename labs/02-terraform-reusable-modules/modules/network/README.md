# Module: network

Creates one Azure virtual network, a set of subnets, and one network security group per subnet.

The module does **not** create the resource group. The caller passes its name and region.

## Usage

```hcl
module "network_dev" {
  source = "./modules/network"

  resource_group_name  = azurerm_resource_group.dev.name
  location             = azurerm_resource_group.dev.location
  virtual_network_name = "vnet-lab02-network-dev-weu-001"
  address_space        = ["10.20.0.0/16"]

  subnets = {
    "snet-app-dev-weu-001"  = { address_prefixes = ["10.20.1.0/24"] }
    "snet-mgmt-dev-weu-001" = { address_prefixes = ["10.20.2.0/24"] }
  }

  tags = { environment = "dev" }
}
```

## Inputs

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `resource_group_name` | `string` | Yes | Existing resource group for the network. |
| `location` | `string` | Yes | Azure region. |
| `virtual_network_name` | `string` | Yes | Name of the virtual network. |
| `address_space` | `list(string)` | Yes | CIDR blocks of the virtual network. |
| `subnets` | `map(object)` | Yes | Subnet name mapped to `address_prefixes`. Names must start with `snet-`. |
| `tags` | `map(string)` | No | Tags for resources that support them. Default: `{}`. |

## Outputs

| Name | Description |
| --- | --- |
| `virtual_network_id` | Resource ID of the virtual network. |
| `virtual_network_name` | Name of the virtual network. |
| `subnet_ids` | Map of subnet names to subnet IDs. |
| `network_security_group_ids` | Map of subnet names to NSG IDs. |

## Resources created

For a call with **N** subnets: 1 virtual network, N subnets, N network security groups, N associations.

## Notes

- NSG names are derived from subnet names: `snet-app-dev-weu-001` gives `nsg-app-dev-weu-001`.
- The NSGs contain only the default Azure rules. Default rules allow traffic inside a virtual network, so separate subnets are not network isolation.
