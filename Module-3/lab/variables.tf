variable "location" {
  type    = string
  default = "westeurope"
}
variable "environment" {
  type    = string
}
variable "storage_account_name" {
  type = string
}
variable "sa_name_suffix" {
  type    = list(string)
}

# Key Vault variables for count example
variable "key_vault_base_name" {
  type        = string
  description = "Base name for Key Vaults"
}

variable "key_vault_count" {
  type        = number
  description = "Number of Key Vaults to create"
  default     = 2
}

variable "key_vault_purposes" {
  type        = list(string)
  description = "List of purposes for Key Vaults (for demonstration)"
  default     = ["secrets", "certificates", "keys"]
}

variable "tenant_id" {
  type        = string
  description = "Azure Active Directory tenant ID"
}