resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project}"
  location = var.location
}

module "storage_account_one" {
  source                   = "./modules/storage_account"
  storage_account_name     = "${var.storage_account_name}one"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "storage_account_two" {
  source                   = "./modules/storage_account"
  storage_account_name     = "${var.storage_account_name}two"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}