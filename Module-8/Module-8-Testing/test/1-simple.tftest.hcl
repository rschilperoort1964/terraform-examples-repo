variables {
  storage_account_name = "satest101"
  environment          = "dev"
}

run "valid_string_concat" {

  command = plan

  assert {
    condition     = azurerm_storage_account.sa.name == "satest101dev"
    error_message = "Storage account name did not match expected"
  }
}

run "valid_default_settings" {

  command = plan

  assert {
    condition     = azurerm_storage_account.sa.account_tier == "Standard"
    error_message = "The account tier of the storage account is not correct"
  }

  assert {
    condition     = azurerm_storage_account.sa.account_replication_type == "LRS"
    error_message = "The account replication type of the storage account is not correct"
  }

  assert {
    condition     = azurerm_storage_account.sa.location == "westeurope"
    error_message = "The location of the storage account is not correct"
  }
}

run "security_settings" {

  command = plan

  assert {
    condition     = azurerm_storage_account.sa.min_tls_version == "TLS1_2"
    error_message = "HTTPS-only traffic is not enforced."
  }

  assert {
    condition     = azurerm_storage_account.sa.shared_access_key_enabled == false
    error_message = "Shared key access is allowed."
  }
}
