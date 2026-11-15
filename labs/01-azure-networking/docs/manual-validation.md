# Lab 01 - Validation and deployment guide

**Audience:** Readers practicing the Azure Terraform workflow.  
**Scope:** Validate the code, review the plan, deploy to a test subscription, verify, and clean up.

> **Use a dedicated test subscription.** Every command that changes Azure is run manually, after reviewing the plan.

## 1. Prerequisites

- Terraform CLI version **1.9 or later**, within the range supported by `versions.tf`.
- Azure CLI and Git installed locally.
- A **dedicated test Azure subscription** with permission to create resource groups and network resources.
- A local clone of this repository, **outside any synchronized folder** (OneDrive, Dropbox): file locks can break Terraform, and the state file must not be synchronized to a cloud drive.

An **Azure tenant** is an identity boundary. An **Azure subscription** is the billing and resource-management scope where the resources are created.

## 2. Open the lab directory

Run these commands in **PowerShell** from the repository root:

```powershell
cd labs/01-azure-networking
terraform version
az version
```

## 3. Sign in and select the subscription

```powershell
az login
az account list --output table
az account set --subscription "<YOUR_TEST_SUBSCRIPTION_ID>"
az account show --query name --output tsv
```

Confirm that the selected subscription is the intended **non-production** environment, then pass it to Terraform for the current session only:

```powershell
$env:ARM_SUBSCRIPTION_ID = az account show --query id --output tsv
```

Never write subscription IDs, secrets, or tokens into Terraform files, and mask them in screenshots.

## 4. Initialize and validate

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
```

Expected result: initialization completes, formatting passes, and Terraform reports `Success! The configuration is valid.`

- `terraform init` downloads the provider and creates `.terraform.lock.hcl`. **Commit the lock file**: it pins the provider version for everyone.
- `.terraform/` and state files are excluded by the repository `.gitignore`.
- Nothing is deployed at this stage.

## 5. Check that the names are free

```powershell
az group exists --name rg-lab01-network-dev-weu-001
```

Expected result: `false`. If it returns `true`, the resource group already exists: stop and investigate.

## 6. Review and save the plan

```powershell
terraform plan -out=tfplan
```

Expected result: `Plan: 8 to add, 0 to change, 0 to destroy.`

1. One resource group.
2. One virtual network (`10.10.0.0/16`).
3. Two subnets (`10.10.1.0/24` and `10.10.2.0/24`).
4. Two network security groups.
5. Two subnet-to-NSG associations.

Read the plan: region, names, and IP prefixes. Stop if it proposes anything unexpected. Saving the plan with `-out` guarantees that the next step applies exactly what you reviewed.

## 7. Deploy

```powershell
terraform apply tfplan
```

Expected result: `Apply complete! Resources: 8 added, 0 changed, 0 destroyed.`

## 8. Verify

```powershell
terraform plan
```

Expected result: `No changes. Your infrastructure matches the configuration.` The configuration and Azure are in sync, and running Terraform again changes nothing.

In the Azure portal, open the resource group `rg-lab01-network-dev-weu-001` and check the virtual network, its two subnets, and the two network security groups. The **Resource visualizer** shows how they are linked.

> **From the field:** Azure also creates `NetworkWatcherRG` with a `NetworkWatcher_<region>` resource. It is created by the platform, not by Terraform, so it is not in the state.

## 9. Review Git status

```powershell
git status --short
```

Only `.terraform.lock.hcl` should appear as a new file. State files, plan files, and `.terraform/` must never be listed.

## 10. Clean up

```powershell
terraform destroy
az group exists --name rg-lab01-network-dev-weu-001
```

Review the destroy plan before confirming with `yes`. Expected result: `Destroy complete! Resources: 8 destroyed.`, then `false`. `NetworkWatcherRG` remains: it belongs to the platform.

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `subscription ID could not be determined` | `ARM_SUBSCRIPTION_ID` not set in this session | Repeat step 3 |
| Resource already exists | Names already used in the subscription | Change the names in `variables.tf` or remove the old resources |
| `Saved plan is stale` | The state changed after the plan was saved | Run `terraform plan -out=tfplan` again |
| Authorization failed | Missing permissions on the subscription | Check your role assignment (Contributor or equivalent) |

## References

- [AzureRM provider authentication via Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
- [Terraform dependency lock file](https://developer.hashicorp.com/terraform/language/files/dependency-lock)
- [Terraform state](https://developer.hashicorp.com/terraform/language/state)
- [Microsoft Learn: Authenticate Terraform to Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate/authenticate-to-azure)
