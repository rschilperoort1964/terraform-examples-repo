resource "azurerm_service_plan" "appserviceplan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Windows"
  sku_name            = "P1v2"
}

resource "azurerm_windows_web_app" "frontwebapp" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.appserviceplan.id

  virtual_network_subnet_id = var.virtual_network_subnet_id

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }
    }
  }

  site_config {}
  app_settings = {
    "WEBSITE_DNS_SERVER" : "168.63.129.16"
    "KeyVaultName" : var.key_vault_name
    "APPINSIGHTS_INSTRUMENTATIONKEY" : var.application_insights_instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" : var.application_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" : "~2"
    "APPINSIGHTS_PROFILERFEATURE_VERSION" : "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION" : "1.0.0"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" : "disabled"
    "DiagnosticServices_EXTENSION_VERSION" : "~3"
    "InstrumentationEngine_EXTENSION_VERSION" : "disabled"
    "SnapshotDebugger_EXTENSION_VERSION" : "disabled"
    "XDT_MicrosoftApplicationInsights_Mode" : "recommended"
    "XDT_MicrosoftApplicationInsights_PreemptSdk" : "disabled"
    "XDT_MicrosoftApplicationInsights_Java" : "1"
    "XDT_MicrosoftApplicationInsights_NodeJS" : "1"
  }

  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPLICATIONINSIGHTS_CONNECTION_STRING ",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "XDT_MicrosoftApplicationInsightsJava",
      "XDT_MicrosoftApplicationInsights_NodeJS",
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_windows_web_app" "frontwebapp-wrapper" {
  name                = azurerm_windows_web_app.frontwebapp.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "appservice_to_keyvault_spn" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_windows_web_app.frontwebapp-wrapper.identity[0].principal_id
}
