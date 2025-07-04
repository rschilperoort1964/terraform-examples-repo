variables {
  storage_account_name = "satest101"
  environment = "dev"
}

run "valid_string_concat" {
  command = plan

  assert {
    condition = azurerm_storage_account.sa.name == "satest101dev"
    error_message = "Storage account name did not match expected"
  }
}