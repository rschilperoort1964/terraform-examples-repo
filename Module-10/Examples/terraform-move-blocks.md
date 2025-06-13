# terraform move blocks guide

## what is the move block?

The `move` block in terraform is a configuration block that allows you to refactor your terraform code by moving resources from one address to another without destroying and recreating them. This is essential when you need to reorganize your terraform configuration while preserving the actual infrastructure resources.

## why use move blocks?

### 1. safe refactoring
Reorganize your terraform code structure without impacting running infrastructure. Move resources between modules, rename resources, or restructure your configuration safely.

### 2. zero downtime changes
Avoid destroying and recreating resources when you need to change their terraform addresses. This is crucial for production environments where downtime must be minimized.

### 3. module reorganization
Move resources in and out of modules as your infrastructure grows and organizational needs change.

### 4. resource renaming
Change resource names in your configuration while maintaining the same underlying infrastructure.

## basic syntax

```hcl
moved {
  from = old_resource_address
  to   = new_resource_address
}
```

The move block tells terraform that the resource at the `from` address should be treated as if it's now at the `to` address in the state file.

## practical examples

### example 1: renaming a resource

When you need to rename a resource for better clarity:

```hcl
# Original resource (to be renamed)
# resource "azurerm_storage_account" "storage" {
#   name                     = "examplestorageacct"
#   resource_group_name      = azurerm_resource_group.main.name
#   location                 = azurerm_resource_group.main.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# New resource with better name
resource "azurerm_storage_account" "main_storage_account" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Move block to handle the rename
moved {
  from = azurerm_storage_account.storage
  to   = azurerm_storage_account.main_storage_account
}
```

### example 2: moving resources into a module

Moving standalone resources into a module for better organization:

```hcl
# Original standalone resources
# resource "azurerm_virtual_network" "main" { ... }
# resource "azurerm_subnet" "internal" { ... }
# resource "azurerm_network_security_group" "main" { ... }

# New module structure
module "networking" {
  source = "./modules/networking"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_address_space = ["10.0.0.0/16"]
  subnet_prefixes    = ["10.0.1.0/24"]
}

# Move blocks for each resource
moved {
  from = azurerm_virtual_network.main
  to   = module.networking.azurerm_virtual_network.main
}

moved {
  from = azurerm_subnet.internal
  to   = module.networking.azurerm_subnet.internal
}

moved {
  from = azurerm_network_security_group.main
  to   = module.networking.azurerm_network_security_group.main
}
```

### example 3: moving resources out of a module

Extracting resources from a module back to the root configuration:

```hcl
# Resources being moved from module to root
resource "azurerm_key_vault" "main" {
  name                = "example-keyvault"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_access_policy" "main" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
  ]

  secret_permissions = [
    "Set",
    "Get",
    "Delete",
  ]
}

# Move blocks to extract from module
moved {
  from = module.security.azurerm_key_vault.main
  to   = azurerm_key_vault.main
}

moved {
  from = module.security.azurerm_key_vault_access_policy.main
  to   = azurerm_key_vault_access_policy.main
}
```

### example 4: reorganizing module instances

Moving resources between different module instances:

```hcl
# Original module instances
module "app_environment_dev" {
  source = "./modules/app-environment"
  
  environment = "dev"
  app_name    = "myapp"
  # ... other configuration
}

module "app_environment_staging" {
  source = "./modules/app-environment"
  
  environment = "staging"
  app_name    = "myapp"
  # ... other configuration
}

# Moving a resource from dev to staging module
moved {
  from = module.app_environment_dev.azurerm_app_service.web
  to   = module.app_environment_staging.azurerm_app_service.web
}
```

### example 5: handling count and for_each changes

Moving from count to for_each or vice versa:

```hcl
# Original resource with count
# resource "azurerm_storage_account" "storage" {
#   count                    = 3
#   name                     = "storage${count.index}"
#   resource_group_name      = azurerm_resource_group.main.name
#   location                 = azurerm_resource_group.main.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# New resource with for_each
resource "azurerm_storage_account" "storage" {
  for_each = toset(["app", "logs", "backup"])
  
  name                     = "storage${each.value}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Move blocks for each instance
moved {
  from = azurerm_storage_account.storage[0]
  to   = azurerm_storage_account.storage["app"]
}

moved {
  from = azurerm_storage_account.storage[1]
  to   = azurerm_storage_account.storage["logs"]
}

moved {
  from = azurerm_storage_account.storage[2]
  to   = azurerm_storage_account.storage["backup"]
}
```

## advanced scenarios

### handling complex module restructuring

```hcl
# Moving resources during major module refactoring
# Old structure: single monolithic module
# New structure: separate modules for different concerns

# Old: module.infrastructure.azurerm_virtual_network.main
# New: module.networking.azurerm_virtual_network.main
moved {
  from = module.infrastructure.azurerm_virtual_network.main
  to   = module.networking.azurerm_virtual_network.main
}

# Old: module.infrastructure.azurerm_key_vault.main
# New: module.security.azurerm_key_vault.main
moved {
  from = module.infrastructure.azurerm_key_vault.main
  to   = module.security.azurerm_key_vault.main
}

# Old: module.infrastructure.azurerm_app_service.main
# New: module.compute.azurerm_app_service.main
moved {
  from = module.infrastructure.azurerm_app_service.main
  to   = module.compute.azurerm_app_service.main
}
```

### conditional moves with validation

```hcl
# Using locals to manage complex moves
locals {
  environment = "production"
  
  # Define move mappings based on environment
  resource_moves = var.environment == "production" ? {
    "old_storage" = "critical_storage"
    "old_app"     = "production_app"
  } : {}
}

# Conditional move blocks
moved {
  from = azurerm_storage_account.old_storage
  to   = azurerm_storage_account.critical_storage
}

moved {
  from = azurerm_app_service.old_app
  to   = azurerm_app_service.production_app
}
```

## best practices

### 1. plan before moving
Always run `terraform plan` to verify the move operations before applying:

```bash
terraform plan
```

The plan should show move operations, not destroy/create operations.

### 2. use descriptive commit messages
When committing move blocks, clearly document what's being moved and why:

```
git commit -m "refactor: move storage resources into dedicated module

- Move azurerm_storage_account.main to module.storage
- Move azurerm_storage_container.logs to module.storage
- Improves code organization and reusability"
```

### 3. remove move blocks after applying
Move blocks are only needed during the transition. Remove them after successful application:

```hcl
# Remove these move blocks after terraform apply succeeds
# moved {
#   from = azurerm_storage_account.old_name
#   to   = azurerm_storage_account.new_name
# }
```

### 4. handle dependencies carefully
Ensure that moved resources maintain their dependency relationships:

```hcl
# When moving resources, verify dependencies are preserved
resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = module.networking.vnet_name  # Updated reference
  address_prefixes     = ["10.0.2.0/24"]
}

moved {
  from = azurerm_virtual_network.main
  to   = module.networking.azurerm_virtual_network.main
}
```

### 5. test in non-production first
Always test move operations in development or staging environments before applying to production.

### 6. document the refactoring
Maintain documentation about why resources were moved:

```hcl
# This file contains move blocks for the Q2 2025 infrastructure refactoring
# Goals:
# - Separate networking resources into dedicated module
# - Consolidate security resources
# - Improve module reusability across environments
```

## workflow for using move blocks

### step 1: identify resources to move
```bash
# List current state to identify resources
terraform state list
```

### step 2: create move blocks
Add the appropriate `moved` blocks to your configuration.

### step 3: plan the changes
```bash
terraform plan
```

Verify that terraform shows move operations, not destroy/create.

### step 4: apply the moves
```bash
terraform apply
```

### step 5: verify the result
```bash
# Check that resources are in their new locations
terraform state list

# Verify the infrastructure is unchanged
terraform plan  # Should show no changes
```

### step 6: clean up
Remove the move blocks from your configuration after successful application.

## troubleshooting common issues

### 1. resource not found
```
Error: Resource not found in state
```
**solution**: verify the `from` address exists in the current state using `terraform state list`.

### 2. target already exists
```
Error: Target resource already exists
```
**solution**: check if the `to` address already exists in state. You may need to import or remove the existing resource first.

### 3. dependency conflicts
```
Error: Dependency cycle
```
**solution**: ensure that moved resources don't create circular dependencies. Move resources in dependency order.

### 4. module version conflicts
```
Error: Module version mismatch
```
**solution**: ensure that the target module version is compatible with the resource being moved.

## when not to use move blocks

1. **cross-provider moves**: move blocks only work within the same provider
2. **major resource changes**: if the resource configuration changes significantly, consider destroy/create
3. **cross-state moves**: moving resources between different state files requires state manipulation commands
4. **emergency situations**: in crisis situations, prioritize stability over code organization

## alternative approaches

### using terraform state commands
For complex scenarios, you might need to use terraform state commands:

```bash
# Move resource in state file directly
terraform state mv 'azurerm_storage_account.old' 'azurerm_storage_account.new'

# Move resource to different module
terraform state mv 'azurerm_virtual_network.main' 'module.networking.azurerm_virtual_network.main'
```

### import blocks (terraform 1.5+)
For resources that need to be imported into terraform:

```hcl
import {
  to = azurerm_storage_account.example
  id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/example"
}
```

## conclusion

Move blocks are a powerful feature for safely refactoring terraform configurations without impacting actual infrastructure. They enable you to maintain clean, organized code while preserving running resources. Always test moves in non-production environments and follow the recommended workflow to ensure successful refactoring operations.
