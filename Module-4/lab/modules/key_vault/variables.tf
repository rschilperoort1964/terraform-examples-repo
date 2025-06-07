variable "key_vault_name" {
  description = "The name of the key vault"
  type        = string
}
variable "location" {
  description = "The location/region where the key vault should be created"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group in which the key vault should be created"
  type        = string
}
variable "enabled_for_disk_encryption" {
  description = "Should the key vault be enabled for disk encryption?"
  type        = bool
  default     = false
}
variable "tenant_id" {
  description = "The tenant ID for the Azure Active Directory tenant in which the key vault should be created"
  type        = string
}
variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for before being permanently deleted"
  type        = number
  default     = 7
}
variable "sku_name" {
  description = "The SKU name of the key vault"
  type        = string
  default     = "standard"
}
variable "enable_rbac_authorization" {
  description = "Should the key vault be enabled for RBAC authorization?"
  type        = bool
  default     = true
}
