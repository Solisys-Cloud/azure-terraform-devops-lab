# Lab 01 - Manual validation and Azure plan

**Audience:** Readers practicing the Azure Terraform workflow.  
**Scope:** Validate the code and preview Azure changes without deploying infrastructure.

> **No deployment in this guide.** Do not run `terraform apply` or `terraform destroy` at this stage.

## 1. Prerequisites

- Terraform CLI version **1.9 or later**, within the range supported by `versions.tf`.
- Azure CLI installed locally.
- Access to a **dedicated test Azure subscription** with permissions to read subscription metadata and plan the lab resources.
- Git checkout of this repository.
- An understanding that an **Azure tenant** is an identity boundary, whereas an **Azure subscription** is the billing and resource-management scope used for these resources.

The GitHub Actions workflow checks formatting and configuration validity without Azure credentials. These manual steps additionally check whether the configuration can produce a plan against the **selected subscription**.

## 2. Open the lab directory

Run these commands in **PowerShell** from the repository root:

```powershell
cd labs/01-azure-networking
terraform version
az version
```

## 3. Sign in and verify the selected subscription

```powershell
az login
az account list --output table
az account set --subscription "<YOUR_TEST_SUBSCRIPTION_ID>"
az account show --output table
```

Before continuing, confirm that the selected subscription and tenant are the intended **non-production** environment.

AzureRM 4.x and later require a subscription ID for planning or applying. Configure it in the **current PowerShell session** without committing subscription-specific values to the repository:

```powershell
$env:ARM_SUBSCRIPTION_ID = az account show --query id --output tsv
```

Do not put client secrets, passwords, credentials, or tokens into Terraform files, command history, or screenshots.

## 4. Initialize and validate the Terraform configuration

```powershell
terraform init
terraform fmt -check -recursive
terraform validate
```

Expected result: initialization completes, formatting passes, and validation reports that the configuration is valid.

- `terraform init` downloads providers and normally creates a `.terraform.lock.hcl` file. **Review and commit the lock file** through a separate branch and pull request.
- `.terraform/` and local state files are excluded through the repository `.gitignore`.
- Local initialization does not deploy Azure resources.

## 5. Preview the intended changes

Run the following command **only after checking the subscription**:

```powershell
terraform plan
```

For a new, empty Terraform state, the planned architecture consists of **eight managed resources**:

1. One resource group.
2. One virtual network (`10.10.0.0/16`).
3. Two subnets (`10.10.1.0/24` and `10.10.2.0/24`).
4. Two network security groups.
5. Two subnet-to-NSG associations.

Review the actions, Azure region, names, and IP prefixes. Stop if the plan proposes unexpected changes, the subscription is wrong, or the resource names might collide with existing resources.

**Important:** A successful `plan` does not prove that a future `apply` will succeed. Azure permissions, policies, subscription quotas, provider registration, and runtime conditions can still block deployment.

## 6. Review Git status

```powershell
git status --short
```

Check that no state files, private variable values, credentials, or plan artifacts will be committed. The generated `.terraform.lock.hcl` is normally version-controlled; it is **not** a secret.

## 7. Stop here

This guide intentionally ends at **reviewing the plan**. The next lab step will document a controlled, manually approved `apply`, resource verification in the Azure portal, and cleanup.

### References

- [AzureRM provider authentication via Azure CLI](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
- [AzureRM provider configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Microsoft Learn: Authenticate Terraform to Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate/authenticate-to-azure)
