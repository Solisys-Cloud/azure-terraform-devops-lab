# Lab 03 - Module Versioning

**Level:** Intermediate  
**Technology:** Azure, Terraform, Git  
**Focus:** Module repository, Git tags, semantic versioning, controlled upgrades  
**Prerequisite:** [Lab 02](../02-terraform-reusable-modules/README.md)  
**Status:** Ready to run in a lab subscription

## Goal

Move the network module of Lab 02 into **its own Git repository**, publish it as version `v1.0.0`, consume it from this lab, then publish `v1.1.0` and upgrade on purpose.

In Lab 02, the module lived in a subfolder: every change reached every caller at once. With a versioned module, each caller decides **when** to upgrade.

## What you build

| Item | Value |
| --- | --- |
| Module repository | `Solisys-Cloud/terraform-azurerm-network` (replace with your own account if you follow along) |
| Versions | Git tags `v1.0.0` and `v1.1.0` |
| Resource group | `rg-lab03-network-dev-weu-001` |
| Virtual network | `vnet-lab03-network-dev-weu-001` (`10.30.0.0/16`) |
| Subnets | `snet-app-dev-weu-001`, `snet-mgmt-dev-weu-001` |

Total: **8 resources** (1 resource group, 1 virtual network, 2 subnets, 2 network security groups, 2 associations).

This lab uses its own resource group and its own state. It does not read or change anything from Labs 01 and 02.

## Learning objectives

1. Explain why a shared module lives in its own repository.
2. Publish a module version with an annotated Git tag.
3. Consume a module from Git with an explicit `ref`.
4. Read a version number: major, minor, patch.
5. Upgrade a module version and prove with a plan that nothing breaks.

## Key ideas

| Idea | Meaning |
| --- | --- |
| Module source | Where Terraform downloads the module from. Here: a Git repository. |
| `ref` | The Git tag, branch, or commit to use. Always a **tag** for shared modules. |
| Tag | A fixed name for one commit. A published tag is never moved. |
| Semantic versioning | `MAJOR.MINOR.PATCH`: breaking change, compatible feature, fix. |
| `terraform init -upgrade` | Downloads the module again after the `ref` changed. |

Without `ref`, Terraform uses the latest commit of the default branch. Your infrastructure could then change although your own code did not.

## Part 1 - Publish the module as v1.0.0

The module code is the one you wrote in Lab 02, with its own README, changelog, and example.

1. On GitHub, create a new **public**, **empty** repository named `terraform-azurerm-network`.
2. Clone it next to this repository and add the module files at its root: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `CHANGELOG.md`, `.gitignore`, and `examples/basic/main.tf`.
3. Check the code before publishing:

```powershell
terraform fmt -check -recursive
cd examples/basic
terraform init -backend=false
terraform validate
cd ../..
```

4. Commit, push, then create and push the tag:

```powershell
git add .
git commit -m "Add network module"
git push -u origin main
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0
```

Expected: the tag `v1.0.0` is visible on GitHub under **Tags**.

## Part 2 - Consume v1.0.0

Run the commands in **PowerShell** from the root of this repository. Use a dedicated test subscription.

### 1. Sign in and select the subscription

```powershell
cd labs/03-module-versioning
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

Expected: `terraform init` reports `Downloading git::https://github.com/...?ref=v1.0.0 for network...`.

Terraform stored a copy of the module in `.terraform/modules/`. Open `.terraform/modules/modules.json` to see which source and version are in use.

### 3. Plan, deploy, verify

```powershell
az group exists --name rg-lab03-network-dev-weu-001
terraform plan -out=tfplan
terraform apply tfplan
terraform plan
```

Expected: `false`, then `Plan: 8 to add, 0 to change, 0 to destroy.`, then `Apply complete! Resources: 8 added`, then `No changes`.

## Part 3 - Publish v1.1.0

Version 1.1.0 adds two things **without breaking callers**:

- an optional subnet attribute `default_outbound_access_enabled`, default `true`;
- a new output `subnet_address_prefixes`.

In the module repository, work on a branch and open a pull request:

```powershell
git switch -c feature/outbound-access-option
```

Make three code changes.

In `variables.tf`, add the optional attribute to the `subnets` type:

```hcl
variable "subnets" {
  description = "Subnets to create. The map key is the subnet name. default_outbound_access_enabled is optional and defaults to true."
  type = map(object({
    address_prefixes                = list(string)
    default_outbound_access_enabled = optional(bool, true)
  }))

  validation {
    condition     = alltrue([for name, subnet in var.subnets : startswith(name, "snet-")])
    error_message = "Every subnet name must start with the prefix snet-."
  }
}
```

In `main.tf`, pass it to the subnet resource:

```hcl
resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # Added in 1.1.0. The default (true) keeps the behavior of 1.0.0.
  default_outbound_access_enabled = each.value.default_outbound_access_enabled
}
```

In `outputs.tf`, add the new output:

```hcl
output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.address_prefixes }
}
```

Document both additions in `README.md` and `CHANGELOG.md`, then check and publish:

```powershell
terraform fmt -check -recursive
cd examples/basic
terraform init -backend=false
terraform validate
cd ../..
git add .
git commit -m "Add outbound access option and subnet prefixes output"
git push -u origin feature/outbound-access-option
```

Open the pull request on GitHub, review **Files changed**, and merge it. Then tag the merged `main`:

```powershell
git switch main
git pull
git tag -a v1.1.0 -m "Add outbound access option and subnet prefixes output"
git push origin v1.1.0
```

## Part 4 - Upgrade on purpose

Back in `labs/03-module-versioning`.

### 1. Prove that nothing changed yet

```powershell
terraform plan
```

Expected: `No changes`. Version 1.1.0 exists, but this lab still pins `v1.0.0`. Publishing a new version does not touch existing callers.

### 2. Change the version

In `main.tf`, change `?ref=v1.0.0` to `?ref=v1.1.0`. Then:

```powershell
terraform init -upgrade
terraform plan
```

Expected: `Downloading ...?ref=v1.1.0`, then `No changes`. This is what a **compatible** release looks like: same inputs, same resources.

If you run `terraform plan` without `terraform init -upgrade`, Terraform stops with `Module source has changed`. This is a protection, not a failure.

### 3. Use the new feature

Add the new output to `outputs.tf`:

```hcl
output "subnet_address_prefixes" {
  description = "Address prefixes, by subnet name."
  value       = module.network.subnet_address_prefixes
}
```

And turn off default outbound access on the management subnet in `main.tf`:

```hcl
"snet-mgmt-dev-weu-001" = {
  address_prefixes                = ["10.30.2.0/24"]
  default_outbound_access_enabled = false
}
```

```powershell
terraform fmt
terraform validate
terraform plan -out=tfplan
```

Expected: a new output, and a change limited to the management subnet. No other resource appears in the plan. Read whether the subnet is updated in place or replaced before you apply.

### 4. Clean up

```powershell
terraform destroy
az group exists --name rg-lab03-network-dev-weu-001
```

Review the destroy plan before typing `yes`. Expected: `Destroy complete! Resources: 8 destroyed.`, then `false`.

## Success criteria

| Check | Expected result |
| --- | --- |
| `terraform init` | Module downloaded from Git at `v1.0.0` |
| First plan | 8 to add |
| Plan after v1.1.0 is published, before changing `ref` | No changes |
| Plan after changing `ref` to `v1.1.0` | No changes |
| Plan after using the new option | Only the management subnet changes |
| Labs 01 and 02 resources | Untouched |

## Exercises

Continue with the [guided exercises and challenges](docs/exercises.md).

## Safety and cost

- Nothing is deployed automatically. You run every `apply` and `destroy` yourself.
- The resources in this lab carry no direct charge at the time of writing. Always check Azure pricing, and remove lab resources when finished.
- A public module repository is readable by everyone: no secrets, no customer names, no subscription IDs.
- Never move or delete a published tag. Other people's deployments may depend on it. A fix is a new version.
- Never commit state files, plan files, or `.terraform/`. Commit `.terraform.lock.hcl`.

> **From the field:** Platform teams publish modules the way software teams publish libraries. Application teams pin a version and upgrade when they are ready, usually through a one-line pull request that shows the plan. The rule that keeps everyone calm: a minor version must produce `No changes` for callers who do not use the new feature. If it does not, it was a major version.

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `Module source has changed` | The `ref` changed after the last `init` | Run `terraform init -upgrade` |
| `Could not download module` or `reference not found` | The tag does not exist on GitHub, or was not pushed | Run `git push origin v1.0.0` in the module repository |
| `Unsupported argument` after an upgrade | The new version removed or renamed an input | Read the module changelog; this is a major change |
| `Unsupported attribute` on `module.network` | The output only exists in a newer version | Check the `ref` and run `terraform init -upgrade` |
| Git asks for credentials during `terraform init` | The module repository is private | Make it public for this lab, or sign in with Git Credential Manager |

## References

- [Module sources: generic Git repository](https://developer.hashicorp.com/terraform/language/modules/sources#generic-git-repository)
- [Module version constraints and upgrades](https://developer.hashicorp.com/terraform/cli/commands/init#child-module-installation)
- [Semantic Versioning](https://semver.org/)
- [Git tagging](https://git-scm.com/book/en/v2/Git-Basics-Tagging)
- [Optional object type attributes](https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes)
