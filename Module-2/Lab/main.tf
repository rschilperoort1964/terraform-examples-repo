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

module "keyvault" {
  source              = "./modules/keyvault"
  keyvault_name       = var.keyvault_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  
  tags = {
    Environment = "development"
    Project     = var.project
  }
}