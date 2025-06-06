
locals {
  dns_zones = {
    web       = "privatelink.azurewebsites.net"
    sql       = "privatelink.database.windows.net"
    key_vault = "privatelink.vaultcore.azure.net"
  }
}

module "private_dns_zone" {
  source = "./modules/dns_zone"

  for_each = local.dns_zones

  resource_group_name = azurerm_resource_group.rg.name
  dns_zone_name       = "privatelink.azurewebsites.net"
  virtual_network_id  = azurerm_virtual_network.vnet.id
}

# resource "azurerm_private_dns_zone" "dnsprivatezone-web" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone" "dnsprivatezone-sql" {
#   name                = "privatelink.database.windows.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone" "dnsprivatezone-keyvault" {
#   name                = "privatelink.vaultcore.azure.net"
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
#   name                  = "${module.naming.dns_zone.name_unique}-link-web"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone-web.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dnsprivatezone-sql-link" {
#   name                  = "${module.naming.dns_zone.name_unique}-link-sql"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone-sql.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "dnsprivatezone-keyvault-link" {
#   name                  = "${module.naming.dns_zone.name_unique}-link-keyvault"
#   resource_group_name   = azurerm_resource_group.rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone-keyvault.name
#   virtual_network_id    = azurerm_virtual_network.vnet.id
# }
