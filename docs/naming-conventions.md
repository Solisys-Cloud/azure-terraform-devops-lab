# Solisys-Cloud Naming Conventions

These conventions apply to the **Solisys-Cloud** Azure learning portfolio. All repository content, code comments, diagrams, and documentation are written in **English**.

## 1. Lab naming

**Directory format:** `NN-topic-description` (two-digit sequence, lowercase, kebab-case).

Examples:

| Lab | Directory | Level |
| --- | --- | --- |
| Lab 01 - Azure Networking Fundamentals with Terraform | `labs/01-azure-networking/` | Beginner |
| Lab 02 - Terraform Reusable Modules | `labs/02-terraform-reusable-modules/` | Beginner |
| Lab 03 - GitHub Actions CI/CD Fundamentals | `labs/03-github-actions-cicd/` | Beginner |
| Lab 04 - Azure Hub & Spoke Networking | `labs/04-azure-hub-spoke/` | Intermediate |

Lab names should be descriptive, unique within each repository, and stable after publishing. New labs can be added or reordered when needed.

## 2. Azure resource prefixes

Use Microsoft Cloud Adoption Framework [resource abbreviation recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

| Azure resource | Prefix | Example |
| --- | --- | --- |
| Resource group | `rg-` | `rg-lab01-network-dev-weu-001` |
| Virtual network | `vnet-` | `vnet-lab01-network-dev-weu-001` |
| Subnet | `snet-` | `snet-app-dev-weu-001` |
| Network security group | `nsg-` | `nsg-app-dev-weu-001` |
| Route table | `rt-` | `rt-app-dev-weu-001` |
| Private endpoint | `pep-` | `pep-storage-dev-weu-001` |

**Important:** These abbreviations are recommended conventions, not Azure naming requirements. Resource-specific restrictions still apply. For example, some Azure resources do not allow hyphens.

## 3. Resource naming pattern

Where Azure resource naming rules permit, use:

```text
<prefix>-<workload>-<environment>-<region>-<instance>
```

- Workload: a short, descriptive name such as `lab01-network`.
- Environment: `dev`, `tst`, or `prod`; introductory labs use `dev`.
- Region: `weu` is a local portfolio shorthand for `westeurope`, not a mandatory Microsoft standard.
- Instance: `001`, `002`, and so on.

## 4. Source control and documentation

- Terraform identifiers: `snake_case`.
- Lab directories: `lowercase-kebab-case`.
- Each lab should include learning objectives, a diagram, code explanation, validation steps, troubleshooting notes, and cleanup instructions.
- Use descriptive Git commits and pull requests.
- Never commit credentials, secrets, `*.tfstate`, `*.tfvars` containing real values, or plan files.
- Review Terraform changes before applying them to Azure.
- **No automatic Azure deployment is enabled by this naming guide.**

## Reference

[Microsoft Learn - Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
