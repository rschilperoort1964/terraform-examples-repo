# terraform data blocks guide

## what are data blocks?

Data blocks in terraform allow you to fetch information about existing resources that are not managed by your current terraform configuration. Instead of creating new resources, data blocks query the provider's API to retrieve information about resources that already exist in your infrastructure.

## why use data blocks?

### 1. reference existing infrastructure
When you need to use information from resources that were created outside of your terraform configuration or by another terraform workspace.

### 2. avoid resource duplication
Instead of recreating existing resources, you can reference them and use their attributes.

### 3. dynamic configuration
Fetch current state information to make your configuration more flexible and environment-aware.

### 4. security and compliance
Access sensitive information like key vault secrets or existing network configurations without hardcoding values.

## basic syntax

```hcl
data "provider_resource_type" "name" {
  # Query parameters to identify the resource
  name                = "existing-resource-name"
  resource_group_name = "existing-rg"
}

# Use the data in other resources
resource "azurerm_virtual_machine" "example" {
  name                = "vm-example"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  # ... other configuration
}
```

## practical examples

### example 1: referencing an existing resource group

```hcl
# Fetch information about an existing resource group
data "azurerm_resource_group" "main" {
  name = "prod-resources-rg"
}

# Use the resource group for new resources
resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = data.azurerm_resource_group.main.name
  location                 = data.azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = data.azurerm_resource_group.main.tags
}
```

### example 2: getting key vault secrets

```hcl
# Reference an existing key vault
data "azurerm_key_vault" "main" {
  name                = "prod-keyvault"
  resource_group_name = "security-rg"
}

# Fetch a secret from the key vault
data "azurerm_key_vault_secret" "db_password" {
  name         = "database-admin-password"
  key_vault_id = data.azurerm_key_vault.main.id
}

# Use the secret in a resource
resource "azurerm_mssql_server" "example" {
  name                         = "example-sqlserver"
  resource_group_name          = data.azurerm_resource_group.main.name
  location                     = data.azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = data.azurerm_key_vault_secret.db_password.value
}
```

### example 3: networking configuration

```hcl
# Reference existing virtual network
data "azurerm_virtual_network" "main" {
  name                = "prod-vnet"
  resource_group_name = "networking-rg"
}

# Reference existing subnet
data "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  virtual_network_name = data.azurerm_virtual_network.main.name
  resource_group_name  = data.azurerm_virtual_network.main.resource_group_name
}

# Create a network interface using existing network
resource "azurerm_network_interface" "main" {
  name                = "example-nic"
  location            = data.azurerm_virtual_network.main.location
  resource_group_name = data.azurerm_virtual_network.main.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
```

### example 4: client configuration and current user

```hcl
# Get current azure client configuration
data "azurerm_client_config" "current" {}

# Get current user information
data "azuread_user" "current" {
  object_id = data.azurerm_client_config.current.object_id
}

# Create a key vault with access policy for current user
resource "azurerm_key_vault" "example" {
  name                = "example-keyvault"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}
```

### example 5: using filters and multiple data sources

```hcl
# Find all resource groups with specific tags
data "azurerm_resource_groups" "environment" {
  # This will return all resource groups, then we can filter
}

locals {
  prod_resource_groups = [
    for rg in data.azurerm_resource_groups.environment.resource_groups :
    rg if lookup(rg.tags, "Environment", "") == "Production"
  ]
}

# Get the latest ubuntu image
data "azurerm_platform_image" "ubuntu" {
  location  = "West Europe"
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-focal"
  sku       = "20_04-lts-gen2"
}

# Create VM with latest ubuntu image
resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  
  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu.publisher
    offer     = data.azurerm_platform_image.ubuntu.offer
    sku       = data.azurerm_platform_image.ubuntu.sku
    version   = data.azurerm_platform_image.ubuntu.version
  }
  
  # ... other configuration
}
```

## best practices

### 1. use descriptive names
Choose clear, descriptive names for your data blocks that indicate what resource they're referencing.

```hcl
# Good
data "azurerm_resource_group" "networking_prod" {
  name = "networking-prod-rg"
}

# Avoid
data "azurerm_resource_group" "rg1" {
  name = "networking-prod-rg"
}
```

### 2. handle missing resources
Use count or for_each to handle cases where the referenced resource might not exist.

```hcl
data "azurerm_key_vault" "optional" {
  count               = var.use_existing_keyvault ? 1 : 0
  name                = var.existing_keyvault_name
  resource_group_name = var.existing_keyvault_rg
}

resource "azurerm_key_vault" "new" {
  count               = var.use_existing_keyvault ? 0 : 1
  name                = "new-keyvault"
  resource_group_name = azurerm_resource_group.example.name
  # ... other configuration
}
```

### 3. validate data sources
Use terraform validate and plan to ensure your data sources return expected results.

### 4. document dependencies
Clearly document what external resources your configuration depends on.

```hcl
# This configuration requires:
# - Resource group "prod-resources-rg" to exist
# - Key vault "prod-keyvault" to exist with appropriate access
# - Virtual network "prod-vnet" to exist in "networking-rg"

data "azurerm_resource_group" "main" {
  name = "prod-resources-rg"
}
```

### 5. use outputs for sharing data
When using data blocks in modules, expose important attributes through outputs.

```hcl
output "existing_vnet_id" {
  description = "ID of the existing virtual network"
  value       = data.azurerm_virtual_network.main.id
}

output "existing_subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    for subnet in data.azurerm_virtual_network.main.subnets :
    subnet.name => subnet.id
  }
}
```

## common data sources in azure

- `azurerm_resource_group` - existing resource groups
- `azurerm_virtual_network` - existing virtual networks
- `azurerm_subnet` - existing subnets
- `azurerm_key_vault` - existing key vaults
- `azurerm_key_vault_secret` - secrets from key vault
- `azurerm_storage_account` - existing storage accounts
- `azurerm_client_config` - current azure client configuration
- `azuread_user` - azure active directory users
- `azurerm_platform_image` - available platform images
- `azurerm_subscription` - current subscription details

## troubleshooting tips

1. **permission issues**: ensure your terraform execution context has read permissions on the resources you're trying to query
2. **resource not found**: verify the resource names and resource group names are correct
3. **multiple matches**: some data sources might return multiple results; use additional filters or indexing
4. **sensitive data**: be careful when outputting sensitive information from data sources

## conclusion

Data blocks are essential for creating flexible, maintainable terraform configurations that can integrate with existing infrastructure. They promote reusability and help avoid duplication while maintaining security best practices.
