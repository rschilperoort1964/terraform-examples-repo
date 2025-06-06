resource "azurerm_key_vault" "keyvault" {
  name                        = module.naming.key_vault.name_unique
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"

    ip_rules = [local.developer_ip]
  }
}

resource "azurerm_private_endpoint" "pe-keyvault" {
  name                = "${module.naming.private_endpoint.name_unique}-keyvault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpointsubnet.id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [module.private_dns_zone["key_vault"].id]
  }

  private_service_connection {
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    name                           = "${azurerm_key_vault.keyvault.name}-psc"
    subresource_names              = ["vault"]
  }

  depends_on = [azurerm_key_vault.keyvault]
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "terraform_keyvault_spn" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
