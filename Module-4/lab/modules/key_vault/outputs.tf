output "key_vault_name" {
  description = "The name of the key vault"
  value       = azurerm_key_vault.kv.name
  
}
output "key_vault_id" {
  description = "The ID of the key vault"
  value       = azurerm_key_vault.kv.id
}