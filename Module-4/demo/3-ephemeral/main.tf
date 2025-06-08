variable "password" {
  type      = string
  ephemeral = true
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "northeurope"
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "mykeyvault334"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "store_secret" {
  name         = "SecretPassword"
  value        = "static-secret-value"
  key_vault_id = azurerm_key_vault.keyvault.id
  
  depends_on = [azurerm_role_assignment.key_vault_secrets_officer]
}

# Example of using ephemeral variable in a local value that won't be persisted
# This demonstrates ephemeral variables without creating outputs
locals {
  ephemeral_password_length = length(var.password)
}