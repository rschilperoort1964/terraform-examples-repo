
resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name_unique
  location = "westeurope"
}

module "frontwebapp" {
  source = "./modules/app_service"

  app_service_name      = module.naming.app_service.name_unique
  app_service_plan_name = module.naming.app_service.name_unique


  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  virtual_network_subnet_id                = azurerm_subnet.webapp_subnet.id
  application_insights_instrumentation_key = azurerm_application_insights.application_insights.instrumentation_key
  application_insights_connection_string   = azurerm_application_insights.application_insights.connection_string
  key_vault_id                             = azurerm_key_vault.keyvault.id
  key_vault_name                           = azurerm_key_vault.keyvault.name
}

module "backendwebapp" {
  source = "./modules/app_service"

  app_service_name      = module.naming.app_service.name_unique
  app_service_plan_name = module.naming.app_service.name_unique

  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  virtual_network_subnet_id                = azurerm_subnet.webapp_subnet.id
  application_insights_instrumentation_key = azurerm_application_insights.application_insights.instrumentation_key
  application_insights_connection_string   = azurerm_application_insights.application_insights.connection_string
  key_vault_id                             = azurerm_key_vault.keyvault.id
  key_vault_name                           = azurerm_key_vault.keyvault.name
}
