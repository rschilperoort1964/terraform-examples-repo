variable "network_security_group_name" {
  type = string
}
variable "network_security_group_rg" {
  type = string
}
variable "location" {
  type = string
  default = "westeurope"
}

variable "nsg_rules" {
  type = map(object({
    name                         = string
    description                  = optional(string)
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
}
variable "subnet_id" {
  type = string
}
variable "network_watcher_flow_log_name" {
  type = string
}
variable "network_watcher_flow_log_storage_account_id" {
  type = string
}
variable "network_watcher_flow_log_retention_policy_days" {
  type    = number
  default = 7
}
variable "nsg_diagnostic_setting_name" {
  type = string
}
variable "log_analytics_workspace_id" {
  type = string
}
variable "log_analytics_workspace_resource_id" {
  type = string
}
variable "nsg_diagnostic_setting_logs" {
  type = list(object({
    category_group    = optional(string)
    category          = optional(string)
    retention_enabled = bool
  }))
  default = [{
    category_group    = "allLogs"
    retention_enabled = false
  }]
  description = "Log categories that need to be enabled in the diagnostic settings. Choose category_group or category, but not both."
}
