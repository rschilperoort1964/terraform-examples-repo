###############################################
# Module Network Security Group
###############################################

# Creating network security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  resource_group_name = var.network_security_group_rg
  location            = var.location
}
# Creating network security group rules
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = var.nsg_rules
  depends_on = [
    azurerm_network_security_group.nsg
  ]

  name                         = each.value.name
  description                  = each.value.description
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = each.value.source_port_range
  source_port_ranges           = each.value.source_port_ranges
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes

  resource_group_name         = var.network_security_group_rg
  network_security_group_name = var.network_security_group_name
}
# Associate network security group to subnet
resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
# Creating NSG FLow Log profile and associate to default Network Watcher
resource "azurerm_network_watcher_flow_log" "nsg_flow_log" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  location                  = "westeurope"
  network_watcher_name      = data.azurerm_network_watcher.network_watcher.name
  resource_group_name       = data.azurerm_network_watcher.network_watcher.resource_group_name
  name                      = var.network_watcher_flow_log_name
  storage_account_id        = var.network_watcher_flow_log_storage_account_id
  enabled                   = true
  retention_policy {
    enabled = true
    days    = var.network_watcher_flow_log_retention_policy_days
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id
    workspace_region      = "westeurope"
    workspace_resource_id = var.log_analytics_workspace_resource_id
    interval_in_minutes   = 10
  }
}

#############################################
# Output
#############################################
output "network_security_group_id" {
  value = azurerm_network_security_group.nsg.id
}
output "network_security_group_name" {
  value = azurerm_network_security_group.nsg.name
}
