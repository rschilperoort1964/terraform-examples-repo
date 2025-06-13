# terraform import guide

## what is terraform import?

Terraform import is the process of bringing existing infrastructure resources that were created outside of terraform into your terraform state and configuration. This allows you to manage previously unmanaged resources using terraform's declarative approach.

## why import existing resources?

### 1. adopt terraform gradually
Start managing existing infrastructure with terraform without recreating everything from scratch. This is essential for organizations transitioning to infrastructure as code.

### 2. avoid downtime
Import critical production resources instead of destroying and recreating them, which would cause service interruptions.

### 3. consolidate management
Bring all infrastructure under a single management paradigm, making operations more consistent and predictable.

### 4. enable automation
Once imported, resources can benefit from terraform's automation capabilities like planned changes, drift detection, and reproducible deployments.

## import methods

### traditional import command (all terraform versions)
```bash
terraform import resource_type.resource_name resource_id
```

**characteristics:**
- Available in all Terraform versions
- Command-line only
- Imports directly into state
- Requires separate configuration file creation
- One-time operation
- Not tracked in version control

### import blocks (terraform 1.5+)
```hcl
import {
  to = resource_type.resource_name
  id = "resource_id"
}
```

**characteristics:**
- Available from Terraform 1.5+
- Declarative and version-controlled
- Part of your Terraform configuration
- Can be planned and reviewed
- Repeatable and reproducible
- Better for team environments

## choosing the right method

| aspect | import command | import blocks |
|--------|----------------|---------------|
| **version support** | all versions | 1.5+ only |
| **version control** | not tracked | tracked in git |
| **team collaboration** | manual process | reproducible |
| **planning** | immediate import | can be planned first |
| **automation** | script-based | declarative |
| **cleanup** | no cleanup needed | remove after import |

### when to use import command
- Using older Terraform versions (< 1.5)
- Need quick one-off imports
- Working alone or in simple scenarios
- Emergency situations requiring immediate import

### when to use import blocks (recommended)
- Using Terraform 1.5+
- Working in a team environment
- Want reproducible imports
- Prefer declarative approach
- Need to review imports before applying
- Want imports tracked in version control

**recommendation**: use import blocks for modern terraform workflows as they align better with infrastructure as code principles and provide superior collaboration and reproducibility.

## practical examples

### example 1: importing a resource group

First, create the resource configuration that matches the existing resource:

```hcl
# Create configuration for existing resource group
resource "azurerm_resource_group" "imported_rg" {
  name     = "existing-prod-rg"
  location = "West Europe"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

Then import using either method:

**method 1: import command**
```bash
terraform import azurerm_resource_group.imported_rg "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/existing-prod-rg"
```

**method 2: import block (terraform 1.5+)**
```hcl
import {
  to = azurerm_resource_group.imported_rg
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/existing-prod-rg"
}

resource "azurerm_resource_group" "imported_rg" {
  name     = "existing-prod-rg"
  location = "West Europe"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### example 2: importing a storage account

```hcl
# Configuration for existing storage account
resource "azurerm_storage_account" "imported_storage" {
  name                     = "existingstorage123"
  resource_group_name      = "existing-prod-rg"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    Environment = "Production"
    Purpose     = "Application Data"
  }
}

# Import block (terraform 1.5+)
import {
  to = azurerm_storage_account.imported_storage
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/existing-prod-rg/providers/Microsoft.Storage/storageAccounts/existingstorage123"
}
```

**using import command:**
```bash
terraform import azurerm_storage_account.imported_storage \
  "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/existing-prod-rg/providers/Microsoft.Storage/storageAccounts/existingstorage123"
```

### example 3: importing virtual network infrastructure

```hcl
# Import virtual network
resource "azurerm_virtual_network" "imported_vnet" {
  name                = "existing-prod-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West Europe"
  resource_group_name = "networking-rg"

  tags = {
    Environment = "Production"
    Team        = "Platform"
  }
}

import {
  to = azurerm_virtual_network.imported_vnet
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/networking-rg/providers/Microsoft.Network/virtualNetworks/existing-prod-vnet"
}

# Import subnet
resource "azurerm_subnet" "imported_subnet" {
  name                 = "default"
  resource_group_name  = "networking-rg"
  virtual_network_name = azurerm_virtual_network.imported_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

import {
  to = azurerm_subnet.imported_subnet
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/networking-rg/providers/Microsoft.Network/virtualNetworks/existing-prod-vnet/subnets/default"
}
```

### example 4: importing app service and plan

```hcl
# Import app service plan first (dependency)
resource "azurerm_service_plan" "imported_plan" {
  name                = "existing-app-plan"
  resource_group_name = "app-resources-rg"
  location            = "West Europe"
  os_type             = "Linux"
  sku_name            = "P1v2"

  tags = {
    Environment = "Production"
    Application = "WebApp"
  }
}

import {
  to = azurerm_service_plan.imported_plan
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/app-resources-rg/providers/Microsoft.Web/serverfarms/existing-app-plan"
}

# Import app service
resource "azurerm_linux_web_app" "imported_app" {
  name                = "existing-web-app"
  resource_group_name = "app-resources-rg"
  location            = "West Europe"
  service_plan_id     = azurerm_service_plan.imported_plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "ENVIRONMENT" = "production"
  }

  tags = {
    Environment = "Production"
    Application = "WebApp"
  }
}

import {
  to = azurerm_linux_web_app.imported_app
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/app-resources-rg/providers/Microsoft.Web/sites/existing-web-app"
}
```

### example 5: importing key vault and secrets

```hcl
# Import key vault
resource "azurerm_key_vault" "imported_kv" {
  name                = "existing-prod-kv"
  location            = "West Europe"
  resource_group_name = "security-rg"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "List",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "List",
    ]
  }

  tags = {
    Environment = "Production"
    Purpose     = "Application Secrets"
  }
}

import {
  to = azurerm_key_vault.imported_kv
  id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/security-rg/providers/Microsoft.KeyVault/vaults/existing-prod-kv"
}

# Import key vault secret
resource "azurerm_key_vault_secret" "imported_secret" {
  name         = "database-connection-string"
  value        = "Server=tcp:server.database.windows.net,1433;Database=prod-db;..." # Actual value from existing secret
  key_vault_id = azurerm_key_vault.imported_kv.id

  tags = {
    Purpose = "Database Connection"
  }
}

import {
  to = azurerm_key_vault_secret.imported_secret
  id = "https://existing-prod-kv.vault.azure.net/secrets/database-connection-string"
}
```

## step-by-step import workflow

### step 1: identify resources to import
```bash
# List existing resources in azure
az resource list --resource-group "existing-prod-rg" --output table

# Get detailed information about specific resource
az storage account show --name "existingstorage123" --resource-group "existing-prod-rg"
```

### step 2: find the resource id
```bash
# Get the full resource id needed for import
az storage account show --name "existingstorage123" --resource-group "existing-prod-rg" --query "id" --output tsv
```

### step 3: create matching configuration
Write terraform configuration that matches the existing resource's current state.

### step 4: import the resource
Using import block (recommended for terraform 1.5+):
```hcl
import {
  to = azurerm_storage_account.imported_storage
  id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/existingstorage123"
}
```

Or using import command:
```bash
terraform import azurerm_storage_account.imported_storage "/subscriptions/.../resourceGroups/.../providers/Microsoft.Storage/storageAccounts/existingstorage123"
```

### step 5: run terraform plan
```bash
terraform plan
```

This will show differences between your configuration and the actual resource state.

### step 6: align configuration with current state
Update your terraform configuration to match the current state of the imported resource.

### step 7: verify no changes needed
```bash
terraform plan
```

Should show "No changes. Your infrastructure matches the configuration."

### step 8: clean up import blocks
Remove import blocks after successful import (they're only needed during the import process).

## finding resource ids

### using azure cli
```bash
# General format for getting resource id
az resource show --name "resource-name" --resource-group "rg-name" --resource-type "Microsoft.Provider/resourceType" --query "id" --output tsv

# Specific examples
az vm show --name "vm-name" --resource-group "rg-name" --query "id" --output tsv
az network vnet show --name "vnet-name" --resource-group "rg-name" --query "id" --output tsv
az keyvault show --name "kv-name" --query "id" --output tsv
```

### using azure portal
1. Navigate to the resource in azure portal
2. Go to "Properties" section
3. Copy the "Resource ID" field

### using terraform data sources
```hcl
# Use data source to get id, then reference in import
data "azurerm_storage_account" "existing" {
  name                = "existingstorage123"
  resource_group_name = "existing-prod-rg"
}

# Reference the id in import block
import {
  to = azurerm_storage_account.imported_storage
  id = data.azurerm_storage_account.existing.id
}
```

## best practices

### 1. start with read-only resources
Begin importing resources that are less critical or have fewer dependencies:

```hcl
# Good starting points for import
# - Resource groups
# - Storage accounts
# - Virtual networks
# - Key vaults (without secrets initially)
```

### 2. handle dependencies in order
Import resources in dependency order, starting with dependencies first:

```hcl
# Import order example:
# 1. Resource group
# 2. Virtual network
# 3. Subnet
# 4. Network security group
# 5. Virtual machine
```

### 3. use terraform show for configuration hints
```bash
# After import, use show to see current state
terraform show

# Use this output to help write your configuration
```

### 4. import in small batches
Don't try to import everything at once. Work in small, manageable batches:

```hcl
# Batch 1: Core networking
# Batch 2: Security resources
# Batch 3: Compute resources
# Batch 4: Application resources
```

### 5. backup before importing
```bash
# Backup current state before major import operations
cp terraform.tfstate terraform.tfstate.backup.$(date +%Y%m%d_%H%M%S)
```

### 6. document imported resources
```hcl
# Document what was imported and when
# Imported on 2025-06-13: existing production storage account
# Original creation date: 2024-03-15
# Previous management: Manual azure portal
resource "azurerm_storage_account" "imported_storage" {
  # ...existing code...
}
```

## common challenges and solutions

### 1. configuration drift
**problem**: imported resource configuration doesn't match current state.

**solution**: use `terraform show` and azure cli to understand current configuration:

```bash
# Check current configuration
az storage account show --name "storage123" --resource-group "rg" --output json

# Update terraform configuration to match
```

### 2. missing attributes
**problem**: terraform plan shows changes for attributes not set in configuration.

**solution**: add missing attributes to your configuration:

```hcl
resource "azurerm_storage_account" "imported" {
  name                     = "storage123"
  resource_group_name      = "rg"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Add missing attributes found in terraform plan
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  # ...existing code...
}
```

### 3. complex nested resources
**problem**: resources with complex nested configurations are hard to import correctly.

**solution**: use incremental approach:

```hcl
# Start with basic configuration
resource "azurerm_linux_web_app" "imported" {
  name                = "webapp"
  resource_group_name = "rg"
  location            = "West Europe"
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {}  # Start with empty block
}

# Then gradually add nested configurations based on terraform plan output
```

### 4. secret values
**problem**: terraform tries to change secret values that can't be read.

**solution**: use lifecycle rules or external data sources:

```hcl
resource "azurerm_key_vault_secret" "imported" {
  name         = "secret-name"
  value        = "placeholder"  # Will be ignored
  key_vault_id = azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [value]  # Don't manage the actual secret value
  }
}
```

## tools and automation

### terraform import helper scripts
```bash
#!/bin/bash
# import-helper.sh
# Helper script for bulk imports

RESOURCE_GROUP="existing-prod-rg"
SUBSCRIPTION_ID="12345678-1234-1234-1234-123456789012"

# Function to import storage accounts
import_storage_accounts() {
    local accounts=$(az storage account list --resource-group "$RESOURCE_GROUP" --query "[].name" --output tsv)
    
    for account in $accounts; do
        echo "Importing storage account: $account"
        terraform import "azurerm_storage_account.imported_${account}" \
            "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$account"
    done
}

# Run the import
import_storage_accounts
```

### terraformer tool
Use terraformer for bulk imports:

```bash
# Install terraformer
go install github.com/GoogleCloudPlatform/terraformer/cmd/terraformer@latest

# Generate terraform configuration from existing resources
terraformer import azure --resources=azurerm_storage_account,azurerm_virtual_network \
    --regions=westeurope --resource-group=existing-prod-rg
```

## troubleshooting common errors

### 1. "resource already exists in state"
```
Error: Resource already exists in state
```
**solution**: check if resource is already imported:
```bash
terraform state list | grep "resource_name"
```

### 2. "invalid resource id"
```
Error: Invalid resource ID format
```
**solution**: verify the resource id format using azure cli:
```bash
az resource show --ids "/subscriptions/.../resourceGroups/.../providers/..." --query "id"
```

### 3. "provider configuration not found"
```
Error: Provider configuration not found
```
**solution**: ensure provider is configured:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## conclusion

Importing existing resources into terraform is a crucial skill for adopting infrastructure as code in environments with existing infrastructure. The process requires careful planning, attention to configuration details, and patience to align terraform configuration with current resource state.

Start small, work incrementally, and always test in non-production environments first. With terraform 1.5+ import blocks, the process has become more declarative and easier to manage as part of your regular terraform workflow.

Remember that importing is just the first step - the real value comes from being able to manage, version, and reproduce your infrastructure using terraform's powerful features.
