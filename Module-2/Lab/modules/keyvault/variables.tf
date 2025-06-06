variable "keyvault_name" {
  description = "The name of the Key Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Key Vault."
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "The number of days to retain soft-deleted items."
  type        = number
  default     = 7
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
