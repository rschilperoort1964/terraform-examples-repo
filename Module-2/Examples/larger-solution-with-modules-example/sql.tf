# Random password for SQL server
resource "random_password" "admin_password" {
  length      = 20
  special     = true
  min_numeric = 1
  min_upper   = 1
  min_lower   = 1
  min_special = 1
}

resource "azurerm_mssql_server" "server" {
  name                         = module.naming.sql_server.name_unique
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  administrator_login          = "db_admin"
  administrator_login_password = random_password.admin_password.result
  version                      = "12.0"
}

resource "azurerm_mssql_firewall_rule" "sql_server_allow_development_ip" {
  name             = "ErwinHome"
  server_id        = azurerm_mssql_server.server.id
  start_ip_address = local.developer_ip
  end_ip_address   = local.developer_ip
}

# Create SQL database
resource "azurerm_mssql_database" "db" {
  name      = "${module.naming.sql_server.name_unique}-db"
  server_id = azurerm_mssql_server.server.id

  max_size_gb = 5
  sku_name    = "S0"

  sample_name = "AdventureWorksLT"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_private_endpoint" "my_terraform_endpoint" {
  name                = "${module.naming.private_endpoint.name_unique}-sql"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = azurerm_mssql_server.server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["sql"].id]
  }
}

resource "azurerm_key_vault_secret" "sql-dmin-password" {
  name         = "sql-admin-password"
  key_vault_id = azurerm_key_vault.keyvault.id
  value        = random_password.admin_password.result
}

resource "azurerm_key_vault_secret" "sql-connectionstring-kv-secret" {
  name         = "sql-connectionstring"
  value        = "Server=tcp:${azurerm_mssql_server.server.name}.database.windows.net,1433;Initial Catalog=${azurerm_mssql_database.db.name};Persist Security Info=False;User ID=${local.sql-server-username};Password=${random_password.admin_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = azurerm_key_vault.keyvault.id
}
