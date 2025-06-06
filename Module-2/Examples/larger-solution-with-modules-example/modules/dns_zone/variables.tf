variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created."
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the DNS zone"
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network to which the DNS zone should be linked."
  type        = string
}
