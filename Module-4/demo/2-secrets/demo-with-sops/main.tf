# Create adminpassword.json locally
# Run the following commands to encrypt the file:
# sopskey=$(az keyvault key show --name sops-key --vault-name kv-terraform-advanced --subscription ac11db83-f151-4656-8be6-20991bf18e3a --query key.kid -o tsv)
# sops --encrypt --azure-kv $sopskey adminpassword.json > adminpassword.enc.json

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-advanced-module3-sops"
  location = var.location
}

data "sops_file" "test-secret" {
  source_file = "adminpassword.enc.json"
}

resource "azurerm_postgresql_server" "example" {
  name                         = "psql-module3-sops"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  administrator_login          = var.admin_username
  administrator_login_password = data.sops_file.test-secret.data["admin_password"]
  sku_name                     = "B_Gen5_1"
  version                      = 11
  ssl_enforcement_enabled      = true
}