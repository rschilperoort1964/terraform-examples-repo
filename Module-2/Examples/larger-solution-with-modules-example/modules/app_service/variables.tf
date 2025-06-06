variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "location" {
  type        = string
  description = "The location/region where the resources will be created."
}

variable "app_service_plan_name" {
  type        = string
  description = "The name of the App Service."
}

variable "app_service_name" {
  type        = string
  description = "The name of the App Service."
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "The ID of the subnet to which the App Service should be connected."
}

variable "application_insights_instrumentation_key" {
  type        = string
  description = "The Instrumentation Key of the Application Insights instance."
}

variable "application_insights_connection_string" {
  type        = string
  description = "The Instrumentation Key of the Application Insights instance."
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault."
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault."
}
