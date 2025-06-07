
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

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "westus"
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

resource "azurerm_key_vault_secret" "store_secret" {
  name         = "SecretPassword"
  value        = var.password
  key_vault_id = azurerm_key_vault.keyvault.id
}

ephemeral "azurerm_key_vault_secret" "password" {
  name         = "password"
  key_vault_id = azurerm_key_vault.keyvault.id
}

provider "azurerm" {
  features {}

  alias = "secondary"

  client_secret = ephemeral.azurerm_key_vault_secret.password.value
}