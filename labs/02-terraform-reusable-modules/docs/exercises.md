# Lab 02 - Exercises

Complete the lab first. Each exercise changes the configuration; always read the plan before applying.

## Exercise 1 (guided): add a subnet to one environment

**Goal:** see that a change in the inputs of one module call affects only that environment.

1. In `main.tf`, add a third subnet to the `network_tst` call:

   ```hcl
   "snet-data-tst-weu-001" = { address_prefixes = ["10.21.3.0/24"] }
   ```

2. Run `terraform fmt` and `terraform validate`.
3. Run `terraform plan`.

**Expected:** `Plan: 3 to add, 0 to change, 0 to destroy.` One subnet, one NSG, one association, all under `module.network_tst`. Nothing changes in dev.

4. Apply if you agree with the plan, then run `terraform plan` again and confirm `No changes`.

## Exercise 2 (guided): break the validation rule on purpose

**Goal:** understand how a module protects itself against bad input.

1. Rename the new subnet key to `data-tst-weu-001`, without the `snet-` prefix.
2. Run `terraform plan`.

**Expected:** an error with the message `Every subnet name must start with the prefix snet-.` No resource is changed.

3. Restore the correct name and run `terraform plan` again.

## Exercise 3 (guided): expose a new output

**Goal:** learn that a caller only sees what the module declares.

1. In `outputs.tf` of the root configuration, add:

   ```hcl
   output "dev_virtual_network_name" {
     description = "Name of the dev virtual network."
     value       = module.network_dev.virtual_network_name
   }
   ```

2. Run `terraform plan`.

**Expected:** `Changes to Outputs` with one new output and no resource change.

3. Now try to output `module.network_dev.address_space`. Run `terraform validate` and read the error. The module has no such output.

## Challenge 1: add a module output

Add an output named `address_space` to the module, then use it from the root configuration.

**Success criteria:** `terraform validate` succeeds and `terraform plan` shows only a change to outputs.

<details>
<summary>Show a possible solution</summary>

In `modules/network/outputs.tf`:

```hcl
output "address_space" {
  description = "Address spaces of the virtual network."
  value       = azurerm_virtual_network.this.address_space
}
```

In the root `outputs.tf`:

```hcl
output "dev_address_space" {
  description = "Address spaces of the dev virtual network."
  value       = module.network_dev.address_space
}
```

</details>

## Challenge 2: one module block for all environments

The two module calls are almost identical. Replace them with **one** `module` block that uses `for_each` over a map of environments.

**Hints**

- Describe the environments in a `locals` block: one entry per environment with its address space and subnets.
- `for_each` also works on resources, so the two resource groups can become one block.
- Read the plan carefully before applying.

**Success criteria:** `terraform validate` succeeds and you can explain every line of the plan.

<details>
<summary>Show a possible solution and what the plan will say</summary>

```hcl
locals {
  environments = {
    dev = {
      address_space = ["10.20.0.0/16"]
      subnets = {
        "snet-app-dev-weu-001"  = { address_prefixes = ["10.20.1.0/24"] }
        "snet-mgmt-dev-weu-001" = { address_prefixes = ["10.20.2.0/24"] }
      }
    }
    tst = {
      address_space = ["10.21.0.0/16"]
      subnets = {
        "snet-app-tst-weu-001"  = { address_prefixes = ["10.21.1.0/24"] }
        "snet-mgmt-tst-weu-001" = { address_prefixes = ["10.21.2.0/24"] }
      }
    }
  }
}

resource "azurerm_resource_group" "env" {
  for_each = local.environments

  name     = "rg-lab02-network-${each.key}-weu-001"
  location = var.location
  tags     = merge(var.tags, { environment = each.key })
}

module "network" {
  source   = "./modules/network"
  for_each = local.environments

  resource_group_name  = azurerm_resource_group.env[each.key].name
  location             = azurerm_resource_group.env[each.key].location
  virtual_network_name = "vnet-lab02-network-${each.key}-weu-001"
  address_space        = each.value.address_space
  subnets              = each.value.subnets
  tags                 = merge(var.tags, { environment = each.key })
}
```

The root outputs must change too, for example `module.network["dev"].virtual_network_id`.

**What the plan says, and why it matters:** if the resources are already deployed, the plan proposes to **destroy 16 and add 16**. The Azure resources would be identical, but their Terraform addresses changed, for example from `module.network_dev` to `module.network["dev"]`. Terraform sees new addresses as new resources.

To rename without destroying anything, declare the moves:

```hcl
moved {
  from = module.network_dev
  to   = module.network["dev"]
}

moved {
  from = module.network_tst
  to   = module.network["tst"]
}

moved {
  from = azurerm_resource_group.dev
  to   = azurerm_resource_group.env["dev"]
}

moved {
  from = azurerm_resource_group.tst
  to   = azurerm_resource_group.env["tst"]
}
```

With these blocks, the plan reports the moves and `0 to add, 0 to destroy`.

</details>

## Reflection

1. Why does the module receive the resource group name instead of creating the resource group?
2. What would other teams have to change if you renamed the `subnets` variable?
3. When is refactoring with `moved` blocks safer than destroying and recreating?
