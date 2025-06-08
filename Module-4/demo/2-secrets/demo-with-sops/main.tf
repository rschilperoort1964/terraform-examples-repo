# Create adminpassword.json locally
# Run the following commands to encrypt the file:
# sopskey=$(az keyvault key show --name sops-key --vault-name kvterraformsops3079 --subscription ffbf501f-f220-4b59-8d0a-5068d961cc5f --query key.kid -o tsv)
# sops --encrypt --azure-kv $sopskey adminpassword.json > adminpassword.enc.json

resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-advanced-module3-sops"
  location = var.location
}

data "sops_file" "test-secret" {
  source_file = "adminpassword.enc.json"
}

resource "azurerm_storage_account" "example" {
  name                     = "sopsdemostorage${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Using the decrypted secret as a tag to demonstrate SOPS functionality
  tags = {
    environment = "demo"
    secret_tag  = data.sops_file.test-secret.data["admin_password"]
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}