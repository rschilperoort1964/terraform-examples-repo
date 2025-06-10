output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storageaccount.storage_account_name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}
