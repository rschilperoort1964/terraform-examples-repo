variable "project" {
  description = "The name of the project"
  type        = string
}

variable "location" {
  description = "Azure region to deploy to"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "keyvault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}


