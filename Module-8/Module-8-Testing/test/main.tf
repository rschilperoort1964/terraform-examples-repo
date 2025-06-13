provider "azurerm" {
  features {}
  subscription_id = "f0e483fc-9d2f-4a4b-8aee-887a398ff27e"
}

resource "azurerm_resource_group" "rg" {
  name     = "tftest"
  location = "westeurope"
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.storage_account_name}${var.environment}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "BlobStorage"
  account_replication_type = "LRS"
}