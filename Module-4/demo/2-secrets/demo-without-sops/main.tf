resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-advanced-module5"
  location = var.location
}

# data "azurerm_key_vault" "existing" {
#   name                = "kv-terraform-advanced"
#   resource_group_name = "rg-terraform-advanced"
# }

# data "azurerm_key_vault_secret" "example" {
#   name         = "psql-admin-password"
#   key_vault_id = data.azurerm_key_vault.existing.id
# }

resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurerm_postgresql_server" "example" {
  name                         = "psql-module3"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  administrator_login          = var.admin_username
  administrator_login_password = "Password1234!"
  sku_name                     = "B_Gen5_1"
  version                      = 11
  ssl_enforcement_enabled      = true
}

