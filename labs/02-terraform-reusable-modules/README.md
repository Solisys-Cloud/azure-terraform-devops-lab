# Lab 02 - Terraform Reusable Modules

**Level:** Beginner to intermediate  
**Technology:** Azure, Terraform  
**Focus:** Modules, inputs and outputs, `for_each`, reuse  
**Prerequisite:** [Lab 01](../01-azure-networking/README.md)  
**Status:** Ready to run in a lab subscription

## Goal

Write the network once as a **module**, then call it twice with different values to build a `dev` and a `tst` environment.

In Lab 01, every resource was written by hand. Here the same network becomes a reusable building block.

## What you build

| Environment | Resource group | Virtual network | Subnets |
| --- | --- | --- | --- |
| dev | `rg-lab02-network-dev-weu-001` | `vnet-lab02-network-dev-weu-001` (`10.20.0.0/16`) | `snet-app-dev-weu-001`, `snet-mgmt-dev-weu-001` |
| tst | `rg-lab02-network-tst-weu-001` | `vnet-lab02-network-tst-weu-001` (`10.21.0.0/16`) | `snet-app-tst-weu-001`, `snet-mgmt-tst-weu-001` |

Each subnet gets its own network security group. Total: **16 resources** (2 resource groups, then 7 resources per environment).

This lab uses its own resource groups and its own state. It does not read or change anything from Lab 01.

## Learning objectives

1. Explain what a module is and why teams use modules.
2. Tell the difference between a **root configuration** and a **child module**.
3. Pass values to a module with input variables and read results with outputs.
4. Create several similar resources with `for_each`.
5. Read module resource addresses in a plan, such as `module.network_dev.azurerm_subnet.this["snet-app-dev-weu-001"]`.

## Structure

```text
02-terraform-reusable-modules/
  main.tf            root configuration: provider, resource groups, two module calls
  variables.tf       root inputs
  outputs.tf         root outputs
  versions.tf        Terraform and provider versions
  modules/
    network/         the reusable module
      main.tf        virtual network, subnets, NSGs, associations
      variables.tf   module inputs
      outputs.tf     module outputs
      versions.tf    provider requirements
      README.md      module documentation
  docs/
    exercises.md     guided exercises and challenges
```

## Key ideas

- **Root configuration:** the folder where you run `terraform` commands.
- **Child module:** a folder of Terraform code called with a `module` block.
- **Inputs:** the module's variables. They are the only way to send values in.
- **Outputs:** the only values the caller can read back.
- **`for_each`:** creates one resource per entry of a map. The map key becomes part of the resource address.

The module does not create the resource group and does not configure the provider. The root configuration does both. This keeps the module usable in any subscription and any resource group.

## Run the lab

Run the commands in **PowerShell** from the repository root. Use a dedicated test subscription.

### 1. Sign in and select the subscription

```powershell
cd labs/02-terraform-reusable-modules
az login
az account show --query name --output tsv
$env:ARM_SUBSCRIPTION_ID = az account show --query id --output tsv
```

### 2. Initialize and validate

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
```

Expected: `terraform init` reports `Initializing modules...` and lists `network_dev` and `network_tst`. Validation succeeds.

### 3. Check that the names are free

```powershell
az group exists --name rg-lab02-network-dev-weu-001
az group exists --name rg-lab02-network-tst-weu-001
```

Expected: `false` twice.

### 4. Review and save the plan

```powershell
terraform plan -out=tfplan
```

Expected: `Plan: 16 to add, 0 to change, 0 to destroy.`

Read the resource addresses. Each one starts with `module.network_dev` or `module.network_tst`, except the two resource groups.

### 5. Deploy and verify

```powershell
terraform apply tfplan
terraform plan
terraform output
```

Expected: `Apply complete! Resources: 16 added`, then `No changes`, then four outputs.

### 6. Inspect the state

```powershell
terraform state list
```

Expected: 16 addresses. Notice how `for_each` appears: `azurerm_subnet.this["snet-app-dev-weu-001"]`.

### 7. Clean up

```powershell
terraform destroy
az group exists --name rg-lab02-network-dev-weu-001
az group exists --name rg-lab02-network-tst-weu-001
```

Review the destroy plan before typing `yes`. Expected: `Destroy complete! Resources: 16 destroyed.`, then `false` twice.

## Success criteria

| Check | Expected result |
| --- | --- |
| `terraform validate` | Success |
| First plan | 16 to add |
| Second plan after apply | No changes |
| `terraform state list` | 16 addresses, 14 of them inside a module |
| Lab 01 resources | Untouched |

## Exercises

Continue with the [guided exercises and challenges](docs/exercises.md).

## Safety and cost

- Nothing is deployed automatically. You run every `apply` and `destroy` yourself.
- The resources in this lab (resource groups, virtual networks, subnets, NSGs) carry no direct charge at the time of writing. Always check Azure pricing, and remove lab resources when finished.
- Never commit state files, plan files, or `.terraform/`. Commit `.terraform.lock.hcl`.
- Mask subscription IDs in screenshots.

> **From the field:** Teams rarely write a virtual network by hand twice. A shared module gives every project the same naming, the same security baseline, and one place to fix a mistake. The price is discipline: once other people use your module, every change to its inputs is a change to their code.

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `Module not installed` | `terraform init` was not run after adding a module call | Run `terraform init` |
| `Unsupported argument` in a module block | The argument is not a variable of the module | Compare with `modules/network/variables.tf` |
| `Every subnet name must start with the prefix snet-.` | A subnet key breaks the module's validation rule | Rename the subnet |
| `Unsupported attribute` on `module.network_dev` | The value is not declared as a module output | Add it to `modules/network/outputs.tf` |

## References

- [Terraform modules](https://developer.hashicorp.com/terraform/language/modules)
- [Module blocks](https://developer.hashicorp.com/terraform/language/modules/syntax)
- [The for_each meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)
- [Input variable validation](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules)
