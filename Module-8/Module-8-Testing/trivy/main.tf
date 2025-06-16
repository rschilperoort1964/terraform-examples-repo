variable "environment" {
  type        = string
  description = "The environment in which the resources will be created"
  default = "dev"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
  default = "mytfstatestorageaccount"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default = "mytfstateresourcegroup"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "westeurope"
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
}

output "name" {
  value = azurerm_storage_account.sa.name
}