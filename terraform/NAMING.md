# Azure Naming Module Integration

This Terraform configuration uses the official **Azure/naming** module to ensure all resources follow Azure naming best practices and conventions.

## What is the Azure Naming Module?

The [Azure/naming module](https://registry.terraform.io/modules/Azure/naming/azurerm) is an official Terraform module that:
- ✓ Generates compliant resource names following Azure naming conventions
- ✓ Applies appropriate prefixes for each resource type
- ✓ Handles name length restrictions automatically
- ✓ Ensures character restrictions are met
- ✓ Adds suffix numbering for uniqueness

## Resource Naming Convention

For a project named `solve-wordle`, resources are named:

| Resource Type | Prefix | Example Name |
|--------------|--------|--------------|
| Resource Group | `rg-` | `rg-solve-wordle-001` |
| App Service Plan | `plan-` | `plan-solve-wordle-001` |
| App Service | `app-` | `app-solve-wordle-001` |
| Application Insights | `appi-` | `appi-solve-wordle-001` |

## Benefits

1. **Consistency**: All resources follow the same naming pattern
2. **Compliance**: Meets Azure and organizational naming standards
3. **Clarity**: Resource type is immediately identifiable from the name
4. **Uniqueness**: Automatic suffix numbering prevents conflicts
5. **Validation**: Ensures names meet Azure's character and length restrictions

## Customization

The module is configured with your project name as a suffix:

```hcl
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"
  suffix  = [var.project_name]
}
```

To customize further, edit `terraform/main.tf` and add prefixes or additional suffixes:

```hcl
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.0"
  prefix  = ["myorg"]
  suffix  = [var.project_name, var.environment]
}
```

This would generate names like: `rg-myorg-solve-wordle-production-001`

## References

- [Azure Naming Module Documentation](https://registry.terraform.io/modules/Azure/naming/azurerm)
- [Azure Naming Conventions](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Naming Rules](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
