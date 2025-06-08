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

resource "random_string" "server_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "example" {
  name                         = "sql-module3-${random_string.server_suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = random_password.admin_password.result

  tags = {
    environment = "demo"
  }
}

resource "azurerm_mssql_database" "example" {
  name           = "sqldb-module3"
  server_id      = azurerm_mssql_server.example.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"

  tags = {
    environment = "demo"
  }
}

