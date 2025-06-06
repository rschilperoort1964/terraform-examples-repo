# Storage Account outputs (using for_each)
output "storage_accounts_for_each" {
  description = "Map of storage account names (for_each example)"
  value = {
    for key, sa in module.storage_account_for_each : key => sa.storage_account_name
  }
}

# Key Vault outputs (using count)
output "key_vaults_count" {
  description = "List of Key Vault names (count example)"
  value = [
    for kv in module.key_vault_count : kv.key_vault_name
  ]
}

# Demonstration of the difference between count and for_each
output "count_vs_for_each_explanation" {
  description = "Explanation of the differences between count and for_each"
  value = {
    count_explanation = "With count, we get a list/array of resources indexed by numbers (0, 1, 2, etc.)"
    for_each_explanation = "With for_each, we get a map of resources indexed by the keys we provide"
    count_access_pattern = "Access using: module.key_vault_count[0], module.key_vault_count[1], etc."
    for_each_access_pattern = "Access using: module.storage_account_for_each['one'], module.storage_account_for_each['two'], etc."
  }
}
