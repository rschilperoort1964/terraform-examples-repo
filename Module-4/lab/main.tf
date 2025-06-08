data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tf-advanced-module-5-${var.environment}"
  location = var.location
}

module "key_vault" {
  source                        = "./modules/key_vault"
  key_vault_name                = "kv-tf-advanced-${var.environment}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  value        = random_password.admin_password.result
  key_vault_id = module.key_vault.key_vault_id
}