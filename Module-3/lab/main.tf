resource "azurerm_resource_group" "rg" {
  name     = "rg-terraform-advanced-${var.environment}"
  location = var.location
}

# Storage Account example using for_each
# module "storage_account_count" {
#   source                   = "./modules/storage_account"
#   count                    = 2
#   storage_account_name     = "${var.storage_account_name}${count.index}"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = var.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
# }

# Storage Account example using for_each - each account configured differently based on purpose
module "storage_account_for_each" {
  source                   = "./modules/storage_account"
  for_each                 = toset(var.sa_name_suffix)
  storage_account_name     = "${var.storage_account_name}${var.environment}${each.value}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  # Different configurations based on purpose
  account_tier             = each.value == "logs" ? "Standard" : "Premium"
  account_replication_type = each.value == "logs" ? "LRS" : "ZRS"
}

resource "azurerm_storage_container" "prod_container" {
  for_each             = var.environment == "prod" ? module.storage_account_for_each : {}
  name                 = "prod"
  storage_account_id   = each.value.storage_account_id
  container_access_type = "private"
}

# Key Vault example using count - all vaults are identical (showing limitation of count)
module "key_vault_count" {
  source              = "./modules/keyvault"
  count               = var.key_vault_count
  key_vault_name      = "${var.key_vault_base_name}-${var.environment}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  # With count, all Key Vaults get identical configuration
  # You can't easily make them different based on their purpose
  enabled_for_disk_encryption = false
}