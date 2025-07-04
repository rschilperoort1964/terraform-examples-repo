variable "project" {
  description = "The name of the project"
  type        = string
  default     = "rschilpstoragelab5"
}


variable "location" {
  description = "Azure region to deploy to"
  type        = string
  default     = "westeurope"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "rschilpstoragelab1"
}


