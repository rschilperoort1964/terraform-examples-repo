resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-advanced-${var.environment}"
  location = var.location
}

module "storage_account_for_each" {
  source                   = "./modules/storage_account"
  for_each                 = toset(var.sa_name_suffix)
  storage_account_name     = "${var.storage_account_name}${var.environment}${each.value}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

resource "azurerm_storage_container" "prod_container" {
  for_each             = var.environment == "prod" ? module.storage_account_for_each : {}
  name                 = "prod"
  storage_account_name = each.value.storage_account_name
}
